#!/bin/bash

#########################################################################################
##### This is program called by Phono3py_Gen to generate and calculate FC2 and FC3 files
#########################################################################################

### 1. Make the folder of coarse mesh, $JobName is the name of the structure to be calculated

JobName=$(sed '1q;d' init)
Cut_Pair=$(sed '9q;d' init)

### 3. Phono3py calculation
    cd ./$JobName/Phono3pyCut$Cut_Pair

    module purge

    nFC2_POSCAR=$(ls POSCAR_FC2-* | wc -l)    
    nFC3_POSCAR=$(ls POSCAR-* | wc -l)

    echo "the number of FC2 POSCAR generated file is: " $nFC2_POSCAR
    echo "the number of FC3 POSCAR generated file is: " $nFC3_POSCAR    

# ### Submit the FC2 jobs
#     module add apps/vasp/5.4.1
#     for (( i=1;i<=$nFC2_POSCAR; i++ ))
#     do
# 	ithFC2=$(printf "%05d" $i)	
#         cd ./Phono3py_FC2/"disp_fc2-$ithFC2"/
#         qsub run.sh
#         cd ..
#         cd ..
#     done    

### Create jobs that are seperated by a given value $1
    mkdir ./FC3_jobs
    rm -r ./FC3_jobs/*

    for (( nFC3=0; nFC3<=$nFC3_POSCAR; nFC3=nFC3+$1 ))
    do
      	ithFC3=$(printf "%05d" $nFC3)	
        echo $ithFC3

        Start=$(($nFC3+1))
        echo "Start is: " $Start
        End=$(($nFC3+$1))

        if (( $End>$nFC3_POSCAR ));then
          echo "Reach the end"
          End=$nFC3_POSCAR
        fi 
        echo "End is: " $End

### ! SBATCH --partition=mri2016 

    # Create run files
        echo "#!/bin/bash
#SBATCH --job-name="$Start"_"$End"_"$JobName"
#SBATCH --partition=mri2016 
#SBATCH --time=47:59:00       
#SBATCH --output=output.%j
#SBATCH --nodes=8
#SBATCH --ntasks-per-node=18
#SBATCH --mem-per-cpu=2056
#SBATCH --mail-type=ALL
#SBATCH --mail-user=longm2@usf.edu

module purge
module add apps/vasp/5.4.1

cd ../
for (( i=$Start;i<=$End;i++ ))
do
  ithFC3=\$(sed \"\${i}q;d\" FC3_FileList.txt)
  temp=\"\$ithFC3\"

  cp ./{INCAR,KPOINTS,POTCAR} ./Phono3pyFC3Cut$Cut_Pair/disp-\${temp: -5}
  cp POSCAR-\${temp: -5} ./Phono3pyFC3Cut$Cut_Pair/disp-\${temp: -5}/POSCAR

  cd ./Phono3pyFC3Cut$Cut_Pair/disp-\${temp: -5}

  mpirun vasp

  rm CHG CHGCAR CONTCAR DOSCAR EIGENVAL IBZKPT OSZICAR OUTCAR PCDAT REPORT WAVECAR XDATCAR INCAR POSCAR POTCAR run.sh KPOINTS

  cd ../../
done
        " >> ./FC3_jobs/"$Start"_"$End".sh
      done

#########################
### Now submit the jobs
#########################

 cd ./FC3_jobs
 
 for (( nFC3=0; nFC3<=$nFC3_POSCAR; nFC3=nFC3+$1 ))
     do
       	ithFC3=$(printf "%05d" $nFC3)	
         echo $ithFC3
 
         Start=$(($nFC3+1))
         End=$(($nFC3+$1))
 
         if (( $End>$nFC3_POSCAR ));then
           echo "Reach the end"
           End=$nFC3_POSCAR
         fi 
         echo "$Start"_"$End".sh
 
         qsub "$Start"_"$End".sh
     done


