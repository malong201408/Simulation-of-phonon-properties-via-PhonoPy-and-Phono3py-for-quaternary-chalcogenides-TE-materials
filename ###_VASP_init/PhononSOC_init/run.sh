#!/bin/bash

#SBATCH --job-name=SOC
#SBATCH --partition=mri2016 
#SBATCH --time=02:59:00
#SBATCH --output=output.%j
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=18
#SBATCH --mem-per-cpu=2048
#SBATCH --mail-type=ALL
#SBATCH --mail-user=longm2@usf.edu

module purge
module add apps/vasp/5.3.5

mpirun vasp
