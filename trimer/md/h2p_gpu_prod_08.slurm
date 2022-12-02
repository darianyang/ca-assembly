#!/bin/bash
#SBATCH --job-name=tod_2m8l_sep_08
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=4
#SBATCH --cluster=gpu
#SBATCH --gres=gpu:4
#SBATCH --partition=a100
#SBATCH --time=72:00:00 
#SBATCH --mail-user=dty7@pitt.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --output=job_logs/slurm_prod_08.out 
#SBATCH --error=job_logs/slurm_prod_08.err 

module purge
module load gcc/8.2.0
module load openmpi/4.0.3
module load amber/22

# echo commands to stdout
set -x

export DO_PARALLEL="mpirun -np 4"

# Executable
SANDER=pmemd.cuda.MPI

# NPT production
$DO_PARALLEL    $SANDER -O             -i 08_prod.in -o 08_prod.out -x 08_prod.nc             -p 2m8l_sep_solv.prmtop -c 07_prod.rst -r 08_prod.rst -inf 08_prod.nfo &&

# make cpptraj input file
echo "parm PDB_TEMP_solv.prmtop"                            > strip/strip_08.in
echo "trajin 08_prod.nc"                               >> strip/strip_08.in

# fancy imaging
echo "unwrap :1-1386"                                       >> strip/strip_08.in
echo "center :1-1386 mass origin"                           >> strip/strip_08.in
echo "image origin center familiar"                         >> strip/strip_08.in

echo "strip/strip :WAT,Cl-,Na+ "                    >> strip/strip_08.in
echo "trajout 08_prod_dry.nc"                          >> strip/strip_08.in
echo "go"                                                   >> strip/strip_08.in
echo "quit"                                                 >> strip/strip_08.in

# run cpptraj to strip water
cpptraj -i strip/strip_08.in > strip/strip_08.out

#sbatch h2p_gpu_prod_09.slurm
