#!/bin/bash

######################################################################
##### Phonon_Gruneissen ##############################################
######################################################################

JobName=$(sed '1q;d' init)
Phonopy_Path=$(sed '4q;d' init)
ATOMS=($(sed '3q;d' init))
FC2_Mesh=$(sed '5q;d' init)
Phonon_Path=$(sed '7q;d' init)

### 1. Go to minus, orig, plus folder to generate the force-constant file

        cd ./$JobName/Gruneissen/minus    
        
        n_file=$(ls -dq *POSCAR-0* | wc -l)
        echo "the number of POSCAR related file is: " $n_file
        n_POSCAR=`echo "$n_file" | bc`
        echo "the number of POSCAR generated file is: " $n_POSCAR
        
        # Make the number in the form of 0** format
        total_POSCAR=$(printf "%03d" $n_POSCAR)
        echo $total_POSCAR
        
        cp phonopy_disp.yaml ./Phonon_Sep/phonopy_disp.yaml
        cp POSCAR ./Phonon_Sep/POSCAR
	cp POSCAR POSCAR-unitcell
        
        echo "#!/bin/bash
        $Phonopy_Path/phonopy -f {001.."$total_POSCAR"}/vasprun.xml
        " > ./Phonon_Sep/Phonon.sh
        
        # Get the FORCE_SETS from minus folder
        cd ./Phonon_Sep
        bash Phonon.sh
        cp FORCE_SETS ../FORCE_SETS

    ### Go to orig folder
        cd ../../orig
        cp phonopy_disp.yaml ./Phonon_Sep/phonopy_disp.yaml
        cp POSCAR ./Phonon_Sep/POSCAR
	cp POSCAR POSCAR-unitcell	
        
        echo "#!/bin/bash
        $Phonopy_Path/phonopy -f {001.."$total_POSCAR"}/vasprun.xml
        " > ./Phonon_Sep/Phonon.sh
        
        # Get the FORCE_SETS from minus folder
        cd ./Phonon_Sep
        bash Phonon.sh
        cp FORCE_SETS ../FORCE_SETS


    ### Go to plus folder
        cd ../../plus
        cp phonopy_disp.yaml ./Phonon_Sep/phonopy_disp.yaml
        cp POSCAR ./Phonon_Sep/POSCAR
	cp POSCAR POSCAR-unitcell	
        
        echo "#!/bin/bash
        $Phonopy_Path/phonopy -f {001.."$total_POSCAR"}/vasprun.xml
        " > ./Phonon_Sep/Phonon.sh
    
        # Get the FORCE_SETS from minus folder
        cd ./Phonon_Sep
        bash Phonon.sh
        cp FORCE_SETS ../FORCE_SETS

	cd ../../
	ls
	

### Go back to Gruneissen folder
    $Phonopy_Path/phonopy-gruneisen orig plus minus --dim="3 3 3" --pa="auto" --band="1/2 1/4 3/4 0 0 0 1/2 1/2 1/2 1/2 0.0 1/2" -p -s -c POSCAR-unitcell
    $Phonopy_Path/phonopy-gruneisen orig plus minus --dim="3 3 3" --pa="auto" --mesh="10 10 10" -p -s -c POSCAR-unitcell --color="RB"
