#!/bin/bash
#SBATCH --job-name=2m8l_sep_PREP_1
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=24
#SBATCH --cluster=smp
#SBATCH --partition=smp
#SBATCH --time=72:00:00
#SBATCH --mail-user=dty7@pitt.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --output=slurm_prep1.out 
#SBATCH --error=slurm_prep1.err 

# load appropriate modules.  First purge all modules then load in intel (a prereq for loading in amber) and then amber 
module purge

#module load intel/2017.3.196
#module load amber/18

module load gcc/8.2.0
module load openmpi/4.0.3
module load amber/22

# echo commands to stdout
set -x

# set variables
export DO_PARALLEL="mpirun -np 24"
SANDER=pmemd.MPI

###################################################
###################################################
###################################################
PDB="2m8l_sep_solv" 
###################################################
###################################################
###################################################

# 10000 step minimization (500 steepest descent)
printf "\nstart min\n\n" 
$DO_PARALLEL \
    pmemd -O \
            -i 02_min.in -o 02_min.out \
            -p ${PDB}.prmtop -c ${PDB}.inpcrd -r 02_min.rst &&
printf "\ndone min\n\n" 

sbatch prep_mpi_2.slurm
