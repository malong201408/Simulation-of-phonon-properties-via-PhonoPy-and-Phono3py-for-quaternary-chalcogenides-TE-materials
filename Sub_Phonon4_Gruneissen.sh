#!/bin/bash

######################################################################
##### Phonon_Gruneissen ##############################################
######################################################################

Phonopy_Path=$(sed '4q;d' init)
ATOMS=($(sed '3q;d' init))
FC2_Mesh=$(sed '5q;d' init)
Phonon_Path=$(sed '7q;d' init)

### Define the scaling factor for Gruneissen parameter calculation
    minusFactor=0.997
    origFactor=1.000
    plusFactor=1.003

### 1. create the folder for 
    if [ ! -d "./$1" ];then
        mkdir ./$1
    fi
    if [ -d "./$1/Gruneissen" ];then
        rm -rf ./$1/Gruneissen
    fi
    if [ ! -d "./$1/Gruneissen" ];then
        mkdir ./$1/Gruneissen
    fi
    
    mkdir ./$1/Gruneissen/minus
    mkdir ./$1/Gruneissen/orig
    mkdir ./$1/Gruneissen/plus

### 2. Copy the INCAR, KPOINTS, CONTCAR->POSCAR, run.sh, POTCAR to three seperate folders

    cp ./###_VASP_init/Gruneissen_init/{run.sh,INCAR,KPOINTS}  ./$1/Gruneissen/minus     # Copy INCAR, KPOINTS, run.sh
    cp ./###_VASP_init/Gruneissen_init/{run.sh,INCAR,KPOINTS}  ./$1/Gruneissen/orig      # Copy INCAR, KPOINTS, run.sh
    cp ./###_VASP_init/Gruneissen_init/{run.sh,INCAR,KPOINTS}  ./$1/Gruneissen/plus      # Copy INCAR, KPOINTS, run.sh     

    sed -i "1s/SYSTEM/SYSTEM = $1_Gruneissen/g" ./$1/Gruneissen/minus/INCAR       # Change the system name in INCAR file
#    sed -i "s/job-name/job-name=$1/g"  ./$1/Gruneissen/minus/run.sh

    sed -i "1s/SYSTEM/SYSTEM = $1_Gruneissen/g" ./$1/Gruneissen/orig/INCAR       # Change the system name in INCAR file
#    sed -i "s/job-name/job-name=$1/g"  ./$1/Gruneissen/orig/run.sh

    sed -i "1s/SYSTEM/SYSTEM = $1_Gruneissen/g" ./$1/Gruneissen/plus/INCAR       # Change the system name in INCAR file
#    sed -i "s/job-name/job-name=$1/g"  ./$1/Gruneissen/plus/run.sh    
    
    cp ./$1/5_Full_Relax2/POTCAR ./$1/Gruneissen/minus/POTCAR   # Copy POSCAR and change meshing parameter
    cp ./$1/5_Full_Relax2/POTCAR ./$1/Gruneissen/orig/POTCAR   # Copy POSCAR and change meshing parameter
    cp ./$1/5_Full_Relax2/POTCAR ./$1/Gruneissen/plus/POTCAR   # Copy POSCAR and change meshing parameter    

    
    ##### Extract the ENMAX information from POTCAR file and store it in an array for further use
    
    ENMAX_String=$(grep -o -P 'ENMAX.{0,12}' ./$1/Gruneissen/minus/POTCAR)
    ENMAX=($ENMAX_String)
    EnmaxArray=(${ENMAX[2]} ${ENMAX[5]} ${ENMAX[8]} ${ENMAX[11]})
    
    ### Find the maximum value of the ENMAX array
    IFS=$'\n'
    En_Max=$(echo "${EnmaxArray[*]}" | sort -nr | head -n1;)
    ENCUT=`echo "$En_Max*1.3" | bc`
    
    sed -i "s/ENCUT/ENCUT = $ENCUT/g"  ./$1/Gruneissen/minus/INCAR
    sed -i "s/ENCUT/ENCUT = $ENCUT/g"  ./$1/Gruneissen/orig/INCAR
    sed -i "s/ENCUT/ENCUT = $ENCUT/g"  ./$1/Gruneissen/plus/INCAR

    # Very important, change the lattice parameter for minus and plus calculations    
    cp ./$1/5_Full_Relax2/CONTCAR ./$1/Gruneissen/minus/POSCAR
    cp ./$1/5_Full_Relax2/CONTCAR ./$1/Gruneissen/orig/POSCAR
    cp ./$1/5_Full_Relax2/CONTCAR ./$1/Gruneissen/plus/POSCAR

    var=$(sed -n '2p' ./$1/5_Full_Relax2/CONTCAR)
    echo $var
    minusPOSCAR=`echo "$var*$minusFactor" | bc`
    plusPOSCAR=`echo "$var*$plusFactor" | bc`    
    sed -i "2s/$var/$minusPOSCAR/g" ./$1/Gruneissen/minus/POSCAR
    sed -i "2s/$var/$plusPOSCAR/g" ./$1/Gruneissen/plus/POSCAR    

    
### 3. Now generate calculation files for minus, orig, plus
    
 ## 3.1 Files for minus    
    cd ./$1/Gruneissen/minus    
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
        sed -i "3s/job-name/job-name=minusPh$i$1/g" ./Phonon_Sep/$i/run.sh
    done
    cd ../../../    


 ## 3.2 Files for orig
    cd ./$1/Gruneissen/orig
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
        sed -i "3s/job-name/job-name=origPh$i$1/g" ./Phonon_Sep/$i/run.sh
    done
    cd ../../../

  ## 3.3 Files for plus
    cd ./$1/Gruneissen/plus
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
        sed -i "3s/job-name/job-name=plusPh$i$1/g" ./Phonon_Sep/$i/run.sh
    done
    cd ../../../    

    ## 3.4 Submit the jobs
    cd ./$1/Gruneissen/minus
    for i in $(seq -w 001 001 $n_POSCAR); do
        cd ./Phonon_Sep/$i/
        sbatch run.sh
        cd ..
        cd ..
    done 
    cd ../../../
    
    cd ./$1/Gruneissen/orig
    for i in $(seq -w 001 001 $n_POSCAR); do
        cd ./Phonon_Sep/$i/
        sbatch run.sh
        cd ..
        cd ..
    done
    cd ../../../    

    cd ./$1/Gruneissen/plus
    for i in $(seq -w 001 001 $n_POSCAR); do
        cd ./Phonon_Sep/$i/
        sbatch run.sh
        cd ..
        cd ..
    done 
    cd ../../../    
    
    

#  ### 1. Copy the band.conf, mesh.conf, pdos.conf, POSCAR, disp.yaml to the Phonon_Sep folder to get the Phonon band and PDOS
#  
#      cp ./###_VASP_init/Phonon_Band_init/{band.conf,mesh.conf,pdos.conf}  ./$1/Phonon/Phonon_Sep 
#      
#      cp ./$1/Phonon/{POSCAR,phonopy_disp.yaml} ./$1/Phonon/Phonon_Sep   # Copy POSCAR and change meshing parameter
#  
#  ### 2. Calculate the Phonon band
#      cd ./$1/Phonon
#  
#      
#      n_file=$(ls -dq *POSCAR* | wc -l)
#      echo "the number of POSCAR related file is: " $n_file
#      n_POSCAR=`echo "$n_file-2" | bc`
#      echo "the number of POSCAR generated file is: " $n_POSCAR
#  
#      nFC2=$(printf "%03d" $n_POSCAR)
#      echo $nFC2
#          
#      cd ./Phonon_Sep
#  
#      
#      ### write content to conf files
#  Phonon_FC2=$(echo "$FC2_Mesh" | tr -d '"')
#  echo $Phonon_FC2
#  
#      echo "ATOM_NAME = "${ATOMS[@]}"
#  DIM = $Phonon_FC2
#  BAND = $(echo "$Phonon_Path" | tr -d '"')
#      " >band.conf
#  
#      echo "ATOM_NAME = "${ATOMS[@]}"
#  DIM = $Phonon_FC2
#  MP = 31 31 31
#      " >mesh.conf
#  
#      echo "ATOM_NAME = "${ATOMS[@]}"
#  DIM = $Phonon_FC2
#  MP = 31 31 31
#  PDOS = 1 2,3 4 5 6
#      " >pdos.conf    
#      
#      
#      echo "#!/bin/bash
#  
#  $Phonopy_Path/phonopy -f {001.."$nFC2"}/vasprun.xml
#  $Phonopy_Path/phonopy -p -s mesh.conf
#  $Phonopy_Path/phonopy -t -p -s mesh.conf
#  $Phonopy_Path/phonopy -p -s pdos.conf
#  $Phonopy_Path/phonopy -p -s band.conf
#          " > Phonon.sh
#  
#      
#      bash Phonon.sh    
