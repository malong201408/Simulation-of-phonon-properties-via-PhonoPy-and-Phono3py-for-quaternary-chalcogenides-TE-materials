#!/bin/bash

#################################################################
# This program generate the general procedure of fine mesh
#################################################################

######  $1 is the structure to be calculated
######  $2 $3 $4 are the meshing density

POTCAR_Path=$(sed '2q;d' init)
echo $POTCAR_Path
ATOMS=($(sed '3q;d' init))
echo $ATOMS


### 1. Make the folder of coarse mesh, $1 is the name of the structure to be calculated

if [ ! -d "./$1" ];then
    mkdir ./$1
fi
if [ -d "./$1/10_Fine_Mesh" ];then
    rm -rf ./$1/10_Fine_Mesh
fi
if [ ! -d "./$1/10_Fine_Mesh" ];then
    mkdir ./$1/10_Fine_Mesh
fi


## 2. Copy the files to each of the mesh folder
for i in $(seq $2 $3 $4); do
    cp -r ./###_VASP_init/10_Fine_Mesh_init ./$1/10_Fine_Mesh/$i     # Copy INCAR, KPOINTS, run.sh to each of the folder
    sed -i "1s/SYSTEM/SYSTEM = $1/g" ./$1/10_Fine_Mesh/$i/INCAR       # Change the system name in INCAR file
    sed -i "3s/job-name/job-name=$1$i/g" ./$1/10_Fine_Mesh/$i/run.sh
    
    cp ./$1/9_Full_Relax3/CONTCAR ./$1/10_Fine_Mesh/$i/POSCAR   # Copy POSCAR and change meshing parameter

    ### Change the lattice parameter
    var=$(sed -n '2p' ./$1/10_Fine_Mesh/$i/POSCAR)
    amesh=`echo "$var*$i" | bc`
    echo $amesh    
    sed -i "2s/$var/$amesh/g" ./$1/10_Fine_Mesh/$i/POSCAR
done

for i in $(seq $2 $3 $4); do
    touch ./$1/10_Fine_Mesh/$i/POTCAR           # Create an empty file to write POTCAR
    
    for j in "${ATOMS[@]}"; do                   # Create POTCAR file frome the potential folder
	cat $POTCAR_Path/$j/POTCAR >> ./$1/10_Fine_Mesh/$i/POTCAR
    done    
done

##### Extract the ENMAX information from POTCAR file and store it in an array for further use
    ENMAX_String=$(grep -o -P 'ENMAX.{0,12}' ./$1/10_Fine_Mesh/$i/POTCAR)
    echo $ENMAX_String
    ENMAX=($ENMAX_String)
    EnmaxArray=(${ENMAX[2]} ${ENMAX[5]} ${ENMAX[8]} ${ENMAX[11]})
    echo ${EnmaxArray[*]}
    
    ### Find the maximum value of the ENMAX array
    IFS=$'\n'
    echo "${EnmaxArray[*]}" | sort -nr | head -n1;
    En_Max=$(echo "${EnmaxArray[*]}" | sort -nr | head -n1;)
    echo The maximum value is: $En_Max
    ENCUT=`echo "$En_Max*1.3" | bc`
    
for i in $(seq $2 $3 $4); do    
    sed -i "s/ENCUT/ENCUT = $ENCUT/g"  ./$1/10_Fine_Mesh/$i/INCAR
done

cd ./$1/10_Fine_Mesh/
for i in $(seq $2 $3 $4); do    
    cd ./$i/
    qsub run.sh
    cd ..
done
