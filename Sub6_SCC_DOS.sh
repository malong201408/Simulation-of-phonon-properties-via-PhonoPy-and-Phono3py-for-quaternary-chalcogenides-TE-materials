#!/bin/bash

######################################################################
##### 6_SCC_DOS ##################################################
######################################################################


### 1. Make the folder of coarse mesh, $1 is the name of the structure to be calculated

if [ ! -d "./$1" ];then
    mkdir ./$1
fi
if [ -d "./$1/6_SCC_DOS" ];then
    rm -rf ./$1/6_SCC_DOS
fi
if [ ! -d "./$1/6_SCC_DOS" ];then
    mkdir ./$1/6_SCC_DOS
fi



### 2. Copy the INCAR, KPOINTS, CONTCAR->POSCAR, run.sh, POTCAR

    cp -r ./###_VASP_init/6_SCC_DOS_init/.  ./$1/6_SCC_DOS     # Copy INCAR, KPOINTS, run.sh to each of the folder
    sed -i "1s/SYSTEM/SYSTEM = $1_Full/g" ./$1/6_SCC_DOS/INCAR       # Change the system name in INCAR file
    sed -i "s/job-name/job-name=$1/g"  ./$1/6_SCC_DOS/run.sh
    
    cp ./$1/9_Full_Relax3/POTCAR ./$1/6_SCC_DOS/POTCAR   # Copy POSCAR and change meshing parameter

    
    ##### Extract the ENMAX information from POTCAR file and store it in an array for further use
    
    ENMAX_String=$(grep -o -P 'ENMAX.{0,12}' ./$1/6_SCC_DOS/POTCAR)
    ENMAX=($ENMAX_String)
    EnmaxArray=(${ENMAX[2]} ${ENMAX[5]} ${ENMAX[8]} ${ENMAX[11]})
    
    ### Find the maximum value of the ENMAX array
    IFS=$'\n'
    En_Max=$(echo "${EnmaxArray[*]}" | sort -nr | head -n1;)
    ENCUT=`echo "$En_Max*1.3" | bc`
    
    sed -i "s/ENCUT/ENCUT = $ENCUT/g"  ./$1/6_SCC_DOS/INCAR

    cp ./$1/9_Full_Relax3/CONTCAR ./$1/6_SCC_DOS/POSCAR

 ##### Submit the job
    cd ./$1/6_SCC_DOS
    qsub run.sh

