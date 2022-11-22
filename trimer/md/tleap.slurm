#!/bin/bash
#SBATCH --job-name=2m8l_sep_tleap
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=1
#SBATCH --cluster=invest
#SBATCH --partition=lchong
#SBATCH --time=72:00:00
#SBATCH --mail-user=dty7@pitt.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --output=slurm_tleap.out 
#SBATCH --error=slurm_tleap.err 

# load appropriate modules.  First purge all modules then load in intel (a prereq for loading in amber) and then amber 
module purge

#module load intel/2017.3.196
#module load amber/18

#module load cuda/11.0
module load gcc/8.2.0
module load openmpi/4.0.3
module load amber/22

# run tleap
tleap -f tleap.in > tleap.out &&

sbatch prep_mpi_1.slurm
