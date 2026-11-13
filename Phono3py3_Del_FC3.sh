#!/bin/bash
JobName=$(sed '1q;d' init)
Phonopy_Path=$(sed '4q;d' init)
FC2_Mesh=$(sed '5q;d' init)
FC3_Mesh=$(sed '6q;d' init)
Phonon_Path=$(sed '7q;d' init)


#### 2. Get the FORCE_CONSTANTS files from the FC2 and FC3 calculations

    cd ./$JobName/Phono3py/Phono3py_FC3
    
    nFC3_POSCAR=$(ls -d */ | wc -l)    
    FC3_Five=$(printf "%05d" $nFC3_POSCAR)
    
    echo "Number of FC3 files is: " $FC3_Five
   

## Delete useless files for FC3   
    
    for((i=1;i<=$nFC3_POSCAR;i++))
    do
        FC3=$(printf "%05d" $i)
        cd disp-$FC3/
        rm INCAR POSCAR POTCAR run.sh KPOINTS
        cd ../
    done    
