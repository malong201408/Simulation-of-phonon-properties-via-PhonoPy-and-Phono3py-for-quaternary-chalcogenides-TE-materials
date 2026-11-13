#!/bin/bash

######################################################################
##### 7_Band ##################################################
######################################################################

### 1. Make the folder of coarse mesh, $1 is the name of the structure to be calculated

if [ ! -d "./$1" ];then
    mkdir ./$1
fi
if [ -d "./$1/7_Band" ];then
    rm -rf ./$1/7_Band
fi
if [ ! -d "./$1/7_Band" ];then
    mkdir ./$1/7_Band
fi


### 2. Copy the INCAR, KPOINTS, CONTCAR->POSCAR, run.sh, POTCAR

    cp ./###_VASP_init/7_Band_init/{run.sh,INCAR}  ./$1/7_Band     # Copy INCAR, KPOINTS, run.sh to each of the folder
    cp ./###_VASP_init/7_Band_init/$1_KPOINTS  ./$1/7_Band/KPOINTS
    sed -i "1s/SYSTEM/SYSTEM = $1_Band/g" ./$1/7_Band/INCAR       # Change the system name in INCAR file
    sed -i "s/job-name/job-name=$1/g"  ./$1/7_Band/run.sh
    
    cp ./$1/5_Full_Relax2/POTCAR ./$1/7_Band/POTCAR   # Copy POSCAR and change meshing parameter

    
    ##### Extract the ENMAX information from POTCAR file and store it in an array for further use
    
    ENMAX_String=$(grep -o -P 'ENMAX.{0,12}' ./$1/7_Band/POTCAR)
    ENMAX=($ENMAX_String)
    EnmaxArray=(${ENMAX[2]} ${ENMAX[5]} ${ENMAX[8]} ${ENMAX[11]})
    
    ### Find the maximum value of the ENMAX array
    IFS=$'\n'
    En_Max=$(echo "${EnmaxArray[*]}" | sort -nr | head -n1;)
    ENCUT=`echo "$En_Max*1.3" | bc`
    
    sed -i "s/ENCUT/ENCUT = $ENCUT/g"  ./$1/7_Band/INCAR

    cp ./$1/6_SCC_DOS/POSCAR ./$1/7_Band/POSCAR
    cp ./$1/6_SCC_DOS/CHGCAR ./$1/7_Band/CHGCAR

 ##### Submit the job
    cd ./$1/7_Band
    qsub run.sh

