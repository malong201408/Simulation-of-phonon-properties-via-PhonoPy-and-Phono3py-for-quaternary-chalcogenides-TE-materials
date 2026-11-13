#!/bin/bash

######################################################################
##### PhononSOC ##################################################
######################################################################

Phonopy_Path=$(sed '4q;d' init)
FC2_Mesh=$(sed '5q;d' init)

MAGMOM=$(sed '8q;d' init)
echo $MAGMOM

### 1. Make the folder of coarse mesh, $1 is the name of the structure to be calculated

if [ ! -d "./$1" ];then
    mkdir ./$1
fi
if [ -d "./$1/PhononSOC" ];then
    rm -rf ./$1/PhononSOC
fi
if [ ! -d "./$1/PhononSOC" ];then
    mkdir ./$1/PhononSOC
fi


### 2. Copy the INCAR, KPOINTS, CONTCAR->POSCAR, run.sh, POTCAR

    cp ./###_VASP_init/PhononSOC_init/{run.sh,INCAR,KPOINTS}  ./$1/PhononSOC     # Copy INCAR, KPOINTS, run.sh 

    sed -i "1s/SYSTEM/SYSTEM = $1_PhononSOC/g" ./$1/PhononSOC/INCAR       # Change the system name in INCAR file
    #sed -i "s/MAGMOM/$MAGMOM/g" ./$1/PhononSOC/INCAR       # Change the system name in INCAR file    
    
    cp ./$1/9_Full_Relax3/POTCAR ./$1/PhononSOC/POTCAR   # Copy POSCAR and change meshing parameter

    
    ##### Extract the ENMAX information from POTCAR file and store it in an array for further use
    
    ENMAX_String=$(grep -o -P 'ENMAX.{0,12}' ./$1/PhononSOC/POTCAR)
    ENMAX=($ENMAX_String)
    EnmaxArray=(${ENMAX[2]} ${ENMAX[5]} ${ENMAX[8]} ${ENMAX[11]})
    
    ### Find the maximum value of the ENMAX array
    IFS=$'\n'
    En_Max=$(echo "${EnmaxArray[*]}" | sort -nr | head -n1;)
    ENCUT=`echo "$En_Max*1.3" | bc`
    
    sed -i "s/ENCUT/ENCUT = $ENCUT/g"  ./$1/PhononSOC/INCAR
    
    cp ./$1/9_Full_Relax3/CONTCAR ./$1/PhononSOC/POSCAR


### Now generate the files in for PhononSOC calculation
    cd ./$1/PhononSOC
    
    module purge
    $Phonopy_Path/phonopy -d --dim=FC2_Replace   

    n_file=$(ls -dq *POSCAR* | wc -l)
    echo "the number of POSCAR related file is: " $n_file
    n_POSCAR=`echo "$n_file-2" | bc`
    echo "the number of POSCAR generated file is: " $n_POSCAR
    echo "Number of atoms in SPOSCAR"
    
    NumAtoms=$(sed '7q;d' SPOSCAR| awk '{for(i=1;i<=NF;i++)sum+=$i; print sum}')
    echo $NumAtoms
    MagNum="$(($NumAtoms*3))"
    echo $MagNum
    
    # Make separate directories
    mkdir ./PhononSOC_Sep
    for i in $(seq -w 001 001 $n_POSCAR); do
        echo $i
        mkdir ./PhononSOC_Sep/$i
        cp POSCAR-$i ./PhononSOC_Sep/$i/POSCAR
        cp INCAR KPOINTS POTCAR run.sh ./PhononSOC_Sep/$i/
    done
    
    # Change the job names
    for i in $(seq -w 001 001 $n_POSCAR); do
        sed -i "3s/job-name/job-name=Ph"$i"SOC_"$1"/g" ./PhononSOC_Sep/$i/run.sh
        sed -i "s/MAGMOM/MAGMOM=$MagNum*0/g" ./PhononSOC_Sep/$i/INCAR       # Change the system name in INCAR file	
    done

#Submit the jobs
    module add apps/vasp/5.4.1    
    for i in $(seq -w 001 001 $n_POSCAR); do
        cd ./PhononSOC_Sep/$i/
        qsub run.sh
        cd ..
        cd ..
    done

