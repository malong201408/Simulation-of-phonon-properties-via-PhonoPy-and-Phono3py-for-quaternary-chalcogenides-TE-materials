#!/bin/bash

#SBATCH --job-name
#SBATCH --partition=mri2016 --qos=mri16_npi
#SBATCH --time=24:00:00
#SBATCH --output=output.%j
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=16
#SBATCH --mem-per-cpu=2048
#SBATCH --mail-user=longm2@usf.edu


module purge
module add apps/vasp/5.4.1

mpirun vasp_std
