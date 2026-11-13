#!/bin/bash

#########################################################################################
##### This is program called by Phono3py_Gen to generate and calculate FC2 and FC3 files
#########################################################################################

### 1. Make the folder of coarse mesh, $1 is the name of the structure to be calculated

Phonopy_Path=$(sed '4q;d' init)
FC2_Mesh=$(sed '5q;d' init)
FC3_Mesh=$(sed '6q;d' init)
Cut_Pair=$(sed '9q;d' init)


if [ ! -d "./$1" ];then
    mkdir ./$1
fi
if [ -d "./$1/Phono3pyCut$Cut_Pair" ];then
    rm -rf ./$1/Phono3pyCut$Cut_Pair
fi
if [ ! -d "./$1/Phono3pyCut$Cut_Pair" ];then
    mkdir ./$1/Phono3pyCut$Cut_Pair
fi

rm ./$1/Phono3pyCut$Cut_Pair/*

### 2. Copy the INCAR, KPOINTS, CONTCAR->POSCAR, run.sh, POTCAR

    cp ./###_VASP_init/Phono3py_init/{run.sh,INCAR,KPOINTS}  ./$1/Phono3pyCut$Cut_Pair     # Copy INCAR, KPOINTS, run.sh for FC3

    cp ./###_VASP_init/Phonon_init/KPOINTS  ./$1/Phono3pyCut$Cut_Pair/KPOINTS_Phonopy     # Copy KPOINTS for FC2
    cp ./###_VASP_init/Phonon_init/run.sh  ./$1/Phono3pyCut$Cut_Pair/run_Phonopy.sh       # Copy run.sh for FC2
    cp ./###_VASP_init/Phonon_init/INCAR  ./$1/Phono3pyCut$Cut_Pair/INCAR_Phonopy         # Copy INCAR for FC2

    sed -i "1s/SYSTEM/SYSTEM = $1_Phonon/g" ./$1/Phono3pyCut$Cut_Pair/INCAR               # Change the system name in INCAR file
    sed -i "1s/SYSTEM/SYSTEM = $1_Phonon/g" ./$1/Phono3pyCut$Cut_Pair/INCAR_Phonopy       # Change the system name in INCAR file

    
    cp ./$1/9_Full_Relax3/POTCAR ./$1/Phono3pyCut$Cut_Pair/POTCAR   # Copy POSCAR and change meshing parameter

    
    ##### Extract the ENMAX information from POTCAR file and store it in an array for further use
    
    ENMAX_String=$(grep -o -P 'ENMAX.{0,12}' ./$1/Phono3pyCut$Cut_Pair/POTCAR)
    ENMAX=($ENMAX_String)
    EnmaxArray=(${ENMAX[2]} ${ENMAX[5]} ${ENMAX[8]} ${ENMAX[11]})
    
    ### Find the maximum value of the ENMAX array
    IFS=$'\n'
    En_Max=$(echo "${EnmaxArray[*]}" | sort -nr | head -n1;)
    ENCUT=`echo "$En_Max*1.3" | bc`
    
    sed -i "s/ENCUT/ENCUT = $ENCUT/g"  ./$1/Phono3pyCut$Cut_Pair/INCAR
    sed -i "s/ENCUT/ENCUT = $ENCUT/g"  ./$1/Phono3pyCut$Cut_Pair/INCAR_Phonopy

    
    cp ./$1/9_Full_Relax3/CONTCAR ./$1/Phono3pyCut$Cut_Pair/POSCAR


### 3. Phono3pyCut$Cut_Pair calculation
    cd ./$1/Phono3pyCut$Cut_Pair
    
    module purge
    
    # Change the cutoff-pair setting to reduce the total number of files
    $Phonopy_Path/phono3py --cutoff-pair=CutPair_Replace -d --dim_fc2=FC2_Replace --dim=FC3_Replace -c POSCAR  

    nFC2_POSCAR=$(ls POSCAR_FC2-* | wc -l)    
    nFC3_POSCAR=$(ls POSCAR-* | wc -l)

    echo "the number of POSCAR generated file is: " $n_POSCAR
    echo "the number of FC2 POSCAR: " $nFC2_POSCAR
    echo "the number of FC3 POSCAR: " $nFC3_POSCAR    


    ## 3.1 Make folder for FC2 calculations
    mkdir ./Phono3pyFC2Cut$Cut_Pair
    for (( i=1;i<=$nFC2_POSCAR; i++ ))
    do
	ithFC2=$(printf "%05d" $i)
        echo $ithFC2
	if [ ! -d "./Phono3pyFC2Cut$Cut_Pair/"disp_fc2-$ithFC2"" ];then
	    mkdir ./Phono3pyFC2Cut$Cut_Pair/"disp_fc2-$ithFC2"
	fi	

        cp POSCAR_FC2-$ithFC2 ./Phono3pyFC2Cut$Cut_Pair/"disp_fc2-$ithFC2"/POSCAR

        cp KPOINTS_Phonopy ./Phono3pyFC2Cut$Cut_Pair/"disp_fc2-$ithFC2"/KPOINTS
        cp INCAR_Phonopy ./Phono3pyFC2Cut$Cut_Pair/"disp_fc2-$ithFC2"/INCAR
        cp run_Phonopy.sh ./Phono3pyFC2Cut$Cut_Pair/"disp_fc2-$ithFC2"/run.sh
        cp POTCAR ./Phono3pyFC2Cut$Cut_Pair/"disp_fc2-$ithFC2"/POTCAR	
	
	sed -i "3s/job-name=Phon/job-name=FC2$ithFC2$1/g" ./Phono3pyFC2Cut$Cut_Pair/"disp_fc2-$ithFC2"/run.sh
    done
    
    ## 3.2 Make folder for FC3 calculations

    # First make a file that store the FC3 files indices

    mkdir ./Phono3pyFC3Cut$Cut_Pair    
    for i in POSCAR-*; do
	echo $i >> FC3_FileList.txt
        temp="$i"
	echo ${temp: -5}
        if [ ! -d "./Phono3pyFC3Cut$Cut_Pair/"disp-${temp: -5}"" ];then
	    mkdir ./Phono3pyFC3Cut$Cut_Pair/"disp-${temp: -5}"
	fi
        cp $i ./Phono3pyFC3Cut$Cut_Pair/"disp-${temp: -5}"/POSCAR
        cp INCAR KPOINTS POTCAR run.sh ./Phono3pyFC3Cut$Cut_Pair/"disp-${temp: -5}"/	
    done
    
        
#    mkdir ./Phono3pyFC3Cut$Cut_Pair
#    for (( i=1;i<=$nFC3_POSCAR; i++ ))
#    do
#	ithFC3=$(printf "%05d" $i)
#        echo $ithFC3
#	if [ ! -d "./Phono3pyFC3Cut$Cut_Pair/"disp-$ithFC3"" ];then
#	    mkdir ./Phono3pyFC3Cut$Cut_Pair/"disp-$ithFC3"
#	fi	
#
#        cp POSCAR-$ithFC3 ./Phono3pyFC3Cut$Cut_Pair/"disp-$ithFC3"/POSCAR
#        cp INCAR KPOINTS POTCAR run.sh ./Phono3pyFC3Cut$Cut_Pair/"disp-$ithFC3"/
#	sed -i "3s/job-name=Phon/job-name=FC3$ithFC3$1/g" ./Phono3pyFC3Cut$Cut_Pair/"disp-$ithFC3"/run.sh
#    done   

