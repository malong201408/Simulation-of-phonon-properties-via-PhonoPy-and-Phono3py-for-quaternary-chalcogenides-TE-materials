#!/bin/bash

#SBATCH --job-name=Phon
#SBATCH --partition=mri2016 --qos=mri16_npi
#SBATCH --time=01:59:00
#SBATCH --output=output.%j
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=18
#SBATCH --mem-per-cpu=2048
#SBATCH --mail-type=ALL
#SBATCH --mail-user=longm2@usf.edu

module purge
module add apps/vasp/5.4.1

mpirun vasp
