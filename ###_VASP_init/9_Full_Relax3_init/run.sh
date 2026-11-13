#!/bin/bash

#SBATCH --job-name
#SBATCH --partition=mri2016
#SBATCH --time=12:00:00
#SBATCH --output=output.%j
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=18
#SBATCH --mem-per-cpu=2560
#SBATCH --mail-type=ALL
#SBATCH --mail-user=longm2@usf.edu

module purge
module add apps/vasp/5.4.1

mpirun vasp
