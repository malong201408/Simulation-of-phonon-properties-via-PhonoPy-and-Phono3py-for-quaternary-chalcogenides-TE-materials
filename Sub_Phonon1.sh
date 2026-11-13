#!/bin/bash

######################################################################
##### Phonon ##################################################
######################################################################

Phonopy_Path=$(sed '4q;d' init)

### 1. Make the folder of coarse mesh, $1 is the name of the structure to be calculated

if [ ! -d "./$1" ];then
    mkdir ./$1
fi
if [ -d "./$1/Phonon" ];then
    rm -rf ./$1/Phonon
fi
if [ ! -d "./$1/Phonon" ];then
    mkdir ./$1/Phonon
fi


### 2. Copy the INCAR, KPOINTS, CONTCAR->POSCAR, run.sh, POTCAR

    cp ./###_VASP_init/Phonon_init/{run.sh,INCAR,KPOINTS}  ./$1/Phonon     # Copy INCAR, KPOINTS, run.sh 

    sed -i "1s/SYSTEM/SYSTEM = $1_Phonon/g" ./$1/Phonon/INCAR       # Change the system name in INCAR file
    sed -i "s/job-name/job-name=$1/g"  ./$1/Phonon/run.sh
    
    cp ./$1/9_Full_Relax3/POTCAR ./$1/Phonon/POTCAR   # Copy POSCAR and change meshing parameter

    
    ##### Extract the ENMAX information from POTCAR file and store it in an array for further use
    
    ENMAX_String=$(grep -o -P 'ENMAX.{0,12}' ./$1/Phonon/POTCAR)
    ENMAX=($ENMAX_String)
    EnmaxArray=(${ENMAX[2]} ${ENMAX[5]} ${ENMAX[8]} ${ENMAX[11]})
    
    ### Find the maximum value of the ENMAX array
    IFS=$'\n'
    En_Max=$(echo "${EnmaxArray[*]}" | sort -nr | head -n1;)
    ENCUT=`echo "$En_Max*1.3" | bc`
    
    sed -i "s/ENCUT/ENCUT = $ENCUT/g"  ./$1/Phonon/INCAR
    
    cp ./$1/9_Full_Relax3/CONTCAR ./$1/Phonon/POSCAR


### Now generate the files in for Phonon calculation
    cd ./$1/Phonon
    
    module purge
    $Phonopy_Path/phonopy -d --dim='3 3 3'   

    n_file=$(ls -dq *POSCAR* | wc -l)
    echo "the number of POSCAR related file is: " $n_file
    n_POSCAR=`echo "$n_file-2" | bc`
    echo "the number of POSCAR generated file is: " $n_POSCAR

    
    # Make separate directories
    mkdir ./Phonon_Sep
    for i in $(seq -w 001 001 $n_POSCAR); do
        echo $i
        mkdir ./Phonon_Sep/$i
        cp POSCAR-$i ./Phonon_Sep/$i/POSCAR
        cp INCAR KPOINTS POTCAR run.sh ./Phonon_Sep/$i/
    done
    
    # Change the job names
    for i in $(seq -w 001 001 $n_POSCAR); do
        sed -i "3s/job-name=/job-name=Ph$i/g" ./Phonon_Sep/$i/run.sh
    done

    #Submit the jobs
    module add apps/vasp/5.4.1    
    for i in $(seq -w 001 001 $n_POSCAR); do
        cd ./Phonon_Sep/$i/
        qsub run.sh
        cd ..
        cd ..
    done

