#!/bin/bash
#SBATCH --job-name=2m8l_sep_PREP_2
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=1
#SBATCH --cluster=gpu
#SBATCH --partition=a100
#SBATCH --gres=gpu:1
#SBATCH --time=72:00:00
#SBATCH --mail-user=dty7@pitt.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --output=slurm_prep2.out 
#SBATCH --error=slurm_prep2.err 

# load appropriate modules.  First purge all modules then load in intel (a prereq for loading in amber) and then amber 
module purge

#module load intel/2017.3.196
#module load amber/18

#module load cuda/11.0
module load gcc/8.2.0
module load openmpi/4.0.3
module load amber/22

# echo commands to stdout
set -x

# set variables
SANDER=pmemd.cuda

###################################################
###################################################
###################################################
PDB="2m8l_sep_solv" 
###################################################
###################################################
###################################################

# 20ps restrained NVT equilibration with Langevin thermostat (298K)
printf "\nstart restrained system heat in\n\n" 
    $SANDER -O \
            -i 03_eq1.in -o 03_eq1.out \
            -p ${PDB}.prmtop -c 02_min.rst -r 03_eq1.rst -ref 02_min.rst &&
printf "\ndone restrained system heat in\n\n" 

# 1 ns restrained NPT equilibration Langevin thermostat (298K) MC barostat (1atm)
printf "\nstart restrained equil\n\n" 
    $SANDER  -O \
            -i 04_eq2.in -o 04_eq2.out \
            -p ${PDB}.prmtop -c 03_eq1.rst -r 04_eq2.rst -ref 03_eq1.rst &&
printf "\ndone restrained equil\n\n" 

# 1 ns distance restrained NPT equilibration Langevin thermostat (298K) MC barostat (1atm)
printf "\nstart unrestrained equil\n\n" 
    $SANDER -O \
            -i 05_eq3_rest.in -o 05_eq3.out \
            -p ${PDB}.prmtop -c 04_eq2.rst -r 05_eq3.rst &&
printf "\ndone unrestrained equil\n\n"

printf "\nSUBMITTING PROD RUN\n" &&

#sbatch h2p_1gpu_prod_06.slurm
