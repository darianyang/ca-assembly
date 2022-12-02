#!/bin/bash
#SBATCH --job-name=tod_2m8l_sep_09
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=1
#SBATCH --cluster=gpu
#SBATCH --gres=gpu:1
#SBATCH --partition=a100
#SBATCH --time=144:00:00 
#SBATCH --mail-user=dty7@pitt.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --output=job_logs/slurm_prod_09.out 
#SBATCH --error=job_logs/slurm_prod_09.err 

module purge
module load gcc/8.2.0
module load openmpi/4.0.3
module load amber/22

# echo commands to stdout
set -x

# Executable
SANDER=pmemd.cuda

# NPT production
    $SANDER -O             -i 09_prod.in -o 09_prod.out -x 09_prod.nc             -p 2m8l_sep_solv.prmtop -c 08_prod.rst -r 09_prod.rst -inf 09_prod.nfo &&

# make cpptraj input file
echo "parm PDB_TEMP_solv.prmtop"                            > strip/strip_09.in
echo "trajin 09_prod.nc"                               >> strip/strip_09.in

# fancy imaging
echo "unwrap :1-1386"                                       >> strip/strip_09.in
echo "center :1-1386 mass origin"                           >> strip/strip_09.in
echo "image origin center familiar"                         >> strip/strip_09.in

echo "strip/strip :WAT,Cl-,Na+ "                    >> strip/strip_09.in
echo "trajout 09_prod_dry.nc"                          >> strip/strip_09.in
echo "go"                                                   >> strip/strip_09.in
echo "quit"                                                 >> strip/strip_09.in

# run cpptraj to strip water
cpptraj -i strip/strip_09.in > strip/strip_09.out

sbatch h2p_gpu_prod_09.slurm
