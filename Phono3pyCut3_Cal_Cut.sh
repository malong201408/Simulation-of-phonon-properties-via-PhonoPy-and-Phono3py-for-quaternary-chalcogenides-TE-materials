#!/bin/bash

JobName=$(sed '1q;d' init)
Phonopy_Path=$(sed '4q;d' init)
FC2_Mesh=$(sed '5q;d' init)
FC3_Mesh=$(sed '6q;d' init)
Phonon_Path=$(sed '7q;d' init)

Cut_Pair=$(sed '9q;d' init)
#Cut_Pair=$1


### 1. Generate the BORN file from Step 6_BRON and copy them to FC2 and FC3 folder

    cd ./$JobName/6_BORN
    $Phonopy_Path/phonopy-vasp-born > BORN
    cd ../../
    
    # Now it's under . folder
    cp ./$JobName/6_BORN/BORN ./$JobName/Phono3pyCut$Cut_Pair/Phono3pyFC2Cut$Cut_Pair/BORN
    cp ./$JobName/6_BORN/BORN ./$JobName/Phono3pyCut$Cut_Pair/Phono3pyFC3Cut$Cut_Pair/BORN
    cp ./$JobName/6_BORN/BORN ./$JobName/Phono3pyCut$Cut_Pair/BORN


#### 2. Get the FORCE_CONSTANTS files from the FC2 and FC3 calculations

    cd ./$JobName/Phono3pyCut$Cut_PairCut$Cut_Pair
    
    nFC2_POSCAR=$(ls POSCAR_FC2-* | wc -l)    
    nFC3_POSCAR=$(ls POSCAR-* | wc -l)
    
    FC2_Five=$(printf "%05d" $nFC2_POSCAR)
    FC3_Five=$(printf "%05d" $nFC3_POSCAR)
    
    echo "Number of FC2 files is: " $FC2_Five
    echo "Number of FC3 files is: " $FC3_Five
    
    cp disp_fc2.yaml ./Phono3pyFC2Cut$Cut_Pair/disp_fc2.yaml
    cp disp_fc3.yaml ./Phono3pyFC3Cut$Cut_Pair/disp_fc3.yaml

    cp POSCAR ./Phono3pyFC2Cut$Cut_Pair/POSCAR
    cp POSCAR ./Phono3pyFC3Cut$Cut_Pair/POSCAR


## Creat calculation files for FC2, force_sets
    echo "#!/bin/bash" > ./Phono3pyFC2Cut$Cut_Pair/FC2_run.sh
    echo "$Phonopy_Path/phono3py --cf2 disp_fc2-{00001..$FC2_Five}/vasprun.xml" >> ./Phono3pyFC2Cut$Cut_Pair/FC2_run.sh
    
    cd  ./Phono3pyFC2Cut$Cut_Pair
    bash FC2_run.sh
    
    # Go back to Phono3pyCut# folder    
    cd ..           
    cp ./Phono3pyFC2Cut$Cut_Pair/FORCES_FC2 ./FORCES_FC2 


## Creat calculation files for FC3, force_sets
        
    echo "#!/bin/bash" > ./Phono3pyFC3Cut$Cut_Pair/FC3_run.sh
    echo "$Phonopy_Path/phono3py --cf3_file file_list.dat" >> ./Phono3pyFC3Cut$Cut_Pair/FC3_run.sh
    
    # Create file list for FC3 force_sets calculation    
    for (( i=1;i<=$nFC3_POSCAR;i++ ))
    do
	ithFC3=$(sed "${i}q;d" FC3_FileList.txt)
	temp="$ithFC3"

	echo disp-${temp: -5}/vasprun.xml 
    done > ./Phono3pyFC3Cut$Cut_Pair/file_list.dat

    cd  ./Phono3pyFC3Cut$Cut_Pair    
    
    bash FC3_run.sh
    cd ..       
    cp ./Phono3pyFC3Cut$Cut_Pair/FORCES_FC3 ./FORCES_FC3 

    
## Create FC2 and FC3 hdf5 files, FC2 and FC3 meshes are different
    echo "#!/bin/bash" > ./FChdf_run.sh
    echo "$Phonopy_Path/phono3py --sym-fc2 --sym-fc3r --dim_fc2="$FC2_Mesh" --dim="$FC3_Mesh" -c POSCAR" >> ./FChdf_run.sh
    bash FChdf_run.sh

    
 ## Band structure calculation
     cp ./fc2.hdf5 ./force_constants.hdf5
     mkdir ./PhononBands
     
     echo "#!/bin/bash" > ./FCband_run.sh
     echo "$Phonopy_Path/phonopy -p -s --dim="$FC2_Mesh" --readfc --readfc-format=HDF5 --band="$Phonon_Path" ">> ./FCband_run.sh
     bash FCband_run.sh    
     mv band.pdf ./PhononBands/"$JobName"_Phonon.pdf
     cp band.yaml ./PhononBands/"$JobName"_Phonon.yaml
     
     echo "#!/bin/bash" > ./FCbandBORN_run.sh
     echo "$Phonopy_Path/phonopy -p -s --dim="$FC2_Mesh" --readfc --readfc-format=HDF5 --band="$Phonon_Path" --nac" >> ./FCbandBORN_run.sh
     bash FCbandBORN_run.sh    
     mv band.pdf ./PhononBands/"$JobName"_Phonon_BORN.pdf
     cp band.yaml ./PhononBands/"$JobName"_Phonon_BORN.yaml    
    
    #bash FCbandBORN_run.sh    

    ### Themo kappa calculation
    mkdir ./Kappa
    echo "#!/bin/bash" > ./FC_Kappa_run.sh 
#    echo "$Phonopy_Path/phono3py --fc3 --fc2 --dim_fc2="$FC2_Mesh" --dim="$FC3_Mesh" --mesh="\"21 21 21\"" -c POSCAR --br --isotope" >> ./FC_Kappa_run.sh
#    bash FC_Kappa_run.sh
#    mv kappa-m212121.hdf5 ./Kappa/"$JobName"Kappa.hdf5
    
    echo "$Phonopy_Path/phono3py --fc3 --fc2 --sym-fc2 --sym-fc3r --dim_fc2="$FC2_Mesh" --dim="$FC3_Mesh" --mesh="\"6 6 6\"" -c POSCAR --br --isotope --nac" >> ./FC_KappaBORN_run.sh
    bash FC_KappaBORN_run.sh
    cp kappa-m666.hdf5 ./Kappa/Cut"$Cut_Pair"_kappa-m666.hdf5


