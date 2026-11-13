#!/bin/bash

######################################################################
##### Phonon_Band ####################################################
######################################################################

Phonopy_Path=$(sed '4q;d' init)
ATOMS=($(sed '3q;d' init))
FC2_Mesh=$(sed '5q;d' init)
Phonon_Path=$(sed '7q;d' init)

### 1. Copy the band.conf, mesh.conf, pdos.conf, POSCAR, disp.yaml to the Phonon_Sep folder to get the Phonon band and PDOS

    cp ./###_VASP_init/Phonon_Band_init/{band.conf,mesh.conf,pdos.conf}  ./$1/Phonon/Phonon_Sep 
    
    cp ./$1/Phonon/{POSCAR,phonopy_disp.yaml} ./$1/Phonon/Phonon_Sep   # Copy POSCAR and change meshing parameter

### 2. Calculate the Phonon band
    cd ./$1/Phonon

    
    n_file=$(ls -dq *POSCAR* | wc -l)
    echo "the number of POSCAR related file is: " $n_file
    n_POSCAR=`echo "$n_file-2" | bc`
    echo "the number of POSCAR generated file is: " $n_POSCAR

    nFC2=$(printf "%03d" $n_POSCAR)
    echo $nFC2
        
    cd ./Phonon_Sep

    
    ### write content to conf files
Phonon_FC2=$(echo "$FC2_Mesh" | tr -d '"')
echo $Phonon_FC2

    echo "ATOM_NAME = "${ATOMS[@]}"
DIM = $Phonon_FC2
BAND = $(echo "$Phonon_Path" | tr -d '"')
    " >band.conf

    echo "ATOM_NAME = "${ATOMS[@]}"
DIM = $Phonon_FC2
MP = 31 31 31
    " >mesh.conf

    echo "ATOM_NAME = "${ATOMS[@]}"
DIM = $Phonon_FC2
MP = 31 31 31
PDOS = 1 2,3 4 5 6
    " >pdos.conf    
    
    
    echo "#!/bin/bash

$Phonopy_Path/phonopy -f {001.."$nFC2"}/vasprun.xml
$Phonopy_Path/phonopy -p -s mesh.conf
$Phonopy_Path/phonopy -t -p -s mesh.conf
$Phonopy_Path/phonopy -p -s pdos.conf
$Phonopy_Path/phonopy -p -s band.conf
        " > Phonon.sh

    
    bash Phonon.sh    
