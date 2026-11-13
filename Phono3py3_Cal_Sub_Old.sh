#!/bin/bash

#SBATCH --job-name=Ag3pykpa
#SBATCH --partition=mri2016 --qos=mri16_npi
#SBATCH --time=47:00:00
#SBATCH --output=output.%j
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --mem-per-cpu=2048
#SBATCH --mail-type=ALL
#SBATCH --mail-user=wshi@mail.usf.edu

JobName=$(sed '1q;d' init)
Phonopy_Path=$(sed '4q;d' init)
FC2_Mesh=$(sed '5q;d' init)
FC3_Mesh=$(sed '6q;d' init)
Phonon_Path=$(sed '7q;d' init)


### 1. Generate the BORN file from Step 6_BRON and copy them to FC2 and FC3 folder

    cd ./$JobName/6_BORN
    $Phonopy_Path/phonopy-vasp-born > BORN
    cd ../../
    
    # Now it's under . folder
    cp ./$JobName/6_BORN/BORN ./$JobName/Phono3py/Phono3py_FC2/BORN
    cp ./$JobName/6_BORN/BORN ./$JobName/Phono3py/Phono3py_FC3/BORN
    cp ./$JobName/6_BORN/BORN ./$JobName/Phono3py/BORN



#### 2. Get the FORCE_CONSTANTS files from the FC2 and FC3 calculations

    cd ./$JobName/Phono3py
    
    nFC2_POSCAR=$(ls POSCAR_FC2-* | wc -l)    
    nFC3_POSCAR=$(ls POSCAR-* | wc -l)
    
    FC2_Five=$(printf "%05d" $nFC2_POSCAR)
    FC3_Five=$(printf "%05d" $nFC3_POSCAR)
    
    echo "Number of FC2 files is: " $FC2_Five
    echo "Number of FC3 files is: " $FC3_Five
    
    cp disp_fc2.yaml ./Phono3py_FC2/disp_fc2.yaml
    cp disp_fc3.yaml ./Phono3py_FC3/disp_fc3.yaml

    cp POSCAR ./Phono3py_FC2/POSCAR
    cp POSCAR ./Phono3py_FC3/POSCAR


## Creat calculation files for FC2
    echo "#!/bin/bash" > ./Phono3py_FC2/FC2_run.sh
    echo "$Phonopy_Path/phono3py --cf2 disp_fc2-{00001..$FC2_Five}/vasprun.xml" >> ./Phono3py_FC2/FC2_run.sh
    
    cd  ./Phono3py_FC2
    bash FC2_run.sh
    cd .. 
    cp ./Phono3py_FC2/FORCES_FC2 ./FORCES_FC2 


## Creat calculation files for FC3
    echo "#!/bin/bash" > ./Phono3py_FC3/FC3_run.sh
    echo "$Phonopy_Path/phono3py --cf3 disp-{00001..$FC3_Five}/vasprun.xml" >> ./Phono3py_FC3/FC3_run.sh
    
    cd  ./Phono3py_FC3
    bash FC3_run.sh
    cd .. 
    cp ./Phono3py_FC3/FORCES_FC3 ./FORCES_FC3 

## FC2 and FC3 hdf5 files, FC2 and FC3 meshes are different
    echo "#!/bin/bash" > ./FChdf_run.sh
    echo "$Phonopy_Path/phono3py --dim_fc2="$FC2_Mesh" --dim="$FC3_Mesh" -c POSCAR" >> ./FChdf_run.sh
    bash FChdf_run.sh
    
## Band structure calculation
    cp ./fc2.hdf5 ./force_constants.hdf5
    mkdir ./PhononBands
    
    echo "#!/bin/bash" > ./FCband_run.sh
    echo "$Phonopy_Path/phonopy -p -s --dim="$FC2_Mesh" --readfc --readfc-format=HDF5 --band="$Phonon_Path" ">> ./FCband_run.sh
    bash FCband_run.sh    
    mv band.pdf ./PhononBands/noBORN.pdf
    
    echo "#!/bin/bash" > ./FCbandBORN_run.sh
    echo "$Phonopy_Path/phonopy -p -s --dim="$FC2_Mesh" --readfc --readfc-format=HDF5 --band="$Phonon_Path" --nac" >> ./FCbandBORN_run.sh
    bash FCbandBORN_run.sh    
    mv band.pdf ./PhononBands/BORN.pdf
    
    #bash FCbandBORN_run.sh    

    ### Themo kappa calculation
    mkdir ./Kappa
    echo "#!/bin/bash" > ./FC_Kappa_run.sh 
    echo "$Phonopy_Path/phono3py --fc3 --fc2 --dim_fc2="$FC2_Mesh" --dim="$FC3_Mesh" --mesh="\"21 21 21\"" -c POSCAR --br --isotope" >> ./FC_Kappa_run.sh
    bash FC_Kappa_run.sh
    mv kappa-m212121.hdf5 ./Kappa/"$JobName"Kappa.hdf5
    
    echo "$Phonopy_Path/phono3py --fc3 --fc2 --dim_fc2="$FC2_Mesh" --dim="$FC3_Mesh" --mesh="\"21 21 21\"" -c POSCAR --br --isotope --nac" >> ./FC_KappaBORN_run.sh
    bash FC_KappaBORN_run.sh
    mv kappa-m212121.hdf5 ./Kappa/"$JobName"KappaBORN.hdf5


