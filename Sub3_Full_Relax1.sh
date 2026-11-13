#!/bin/bash

### In this program, four atom names will be taken as input for bash file
### Then we will form POTCAR file, POSCAR file from the given atoms
### INCAR file's ENMAX value must be read from the file to determine the ENCUT setting


######################################################################
##### 3_Full_Relax1 ##################################################
######################################################################


### 1. Make the folder of coarse mesh, $1 is the name of the structure to be calculated

if [ ! -d "./$1" ];then
    mkdir ./$1
fi
if [ -d "./$1/3_Full_Relax1" ];then
    rm -rf ./$1/3_Full_Relax1
fi
if [ ! -d "./$1/3_Full_Relax1" ];then
    mkdir ./$1/3_Full_Relax1
fi



### 2. Copy the INCAR, KPOINTS, CONTCAR->POSCAR, run.sh, POTCAR

    cp -r ./###_VASP_init/3_Full_Relax1_init/.  ./$1/3_Full_Relax1     # Copy INCAR, KPOINTS, run.sh to each of the folder
    sed -i "1s/SYSTEM/SYSTEM = $1_Full/g" ./$1/3_Full_Relax1/INCAR       # Change the system name in INCAR file
    sed -i "s/job-name/job-name=$1/g"  ./$1/3_Full_Relax1/run.sh
    
    cp ./$1/2_Coarse_Mesh/$2/POTCAR ./$1/3_Full_Relax1/POTCAR   # Copy POSCAR and change meshing parameter

    
    ##### Extract the ENMAX information from POTCAR file and store it in an array for further use
    
    ENMAX_String=$(grep -o -P 'ENMAX.{0,12}' ./$1/3_Full_Relax1/POTCAR)
    ENMAX=($ENMAX_String)
    EnmaxArray=(${ENMAX[2]} ${ENMAX[5]} ${ENMAX[8]} ${ENMAX[11]})
    
    ### Find the maximum value of the ENMAX array
    IFS=$'\n'
    En_Max=$(echo "${EnmaxArray[*]}" | sort -nr | head -n1;)
    ENCUT=`echo "$En_Max*1.3" | bc`
    
    sed -i "s/ENCUT/ENCUT = $ENCUT/g"  ./$1/3_Full_Relax1/INCAR



### 3. Copy the minimum CONTCAR->POSCAR
    for i in $(seq $2 $3 $4); do
	echo -n $i " " >> ./$1/3_Full_Relax1/E_Mesh.dat
        tail -n 1 ./$1/2_Coarse_Mesh/$i/OSZICAR | awk '{print $3}' >> ./$1/3_Full_Relax1/E_Mesh.dat
    done
    
    ##### Find the minimum free energy in E_Conv.dat file and name is MinF
    ##### Find the mesh scaling factor, adn store it in MinMesh
    ##### Then copy the CONTCAR file in the corresponding folder 
    
    MinF=$(sort -nk2,2 ./$1/3_Full_Relax1/E_Mesh.dat | head -1)
    MinMesh=$(echo $MinF | head -n1 | cut -d " " -f1)

    
    cp ./$1/2_Coarse_Mesh/$MinMesh/CONTCAR ./$1/3_Full_Relax1/POSCAR
    


 ##### Submit the job
    cd ./$1/3_Full_Relax1
    qsub run.sh

