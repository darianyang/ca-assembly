#!/bin/bash
#SBATCH --job-name=v00_4xfx_sep_PROD_07
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=1 
#SBATCH --cluster=gpu
#SBATCH --gres=gpu:1
#SBATCH --partition=a100 
#SBATCH --time=120:00:00 
#SBATCH --mail-user=dty7@pitt.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --output=slurm_prod_07.out 
#SBATCH --error=slurm_prod_07.err 

# load appropriate modules.  First purge all modules then load in intel (a prereq for loading in amber) and then amber 
module purge
#module load intel/2017.3.196
#module load amber/18

module load gcc/8.2.0
module load openmpi/4.0.3
module load amber/22

# echo commands to stdout
set -x

# Executable
SANDER=pmemd.cuda

# Amber input files and output name
INP=07_prod_rest.in
TOP=4xfx_sep_solv.prmtop
CRD=06_prod.rst
OUT=07_prod

$SANDER  -O     -i   $INP   -p   $TOP   -c   $CRD   -r   $OUT.rst \
        -o   $OUT.out   -e   $OUT.ene   -v   $OUT.vel   -inf $OUT.nfo   -x   $OUT.nc &&

# make cpptraj input file
echo "parm 4xfx_sep_solv.prmtop"                            > strip_07.in
echo "trajin 07_prod.nc"                                    >> strip_07.in
echo "unwrap :1-462"                                        >> strip_07.in
echo "center :1-462 mass origin"                            >> strip_07.in
echo "image origin center familiar"                         >> strip_07.in
echo "strip :WAT,Na+,Cl-"                                   >> strip_07.in
echo "trajout 07_prod_dry.nc"                               >> strip_07.in
echo "go"                                                   >> strip_07.in
echo "quit"                                                 >> strip_07.in

# run cpptraj to strip water
cpptraj -i strip_07.in > strip_07.out

# remove solvated nc file
#if [ -f "07_prod_dry.nc" ] ; then
#    rm 07_prod.nc &&
#    mv 07_prod_dry.nc 07_prod.nc
#fi

sbatch h2p_1gpu_prod_08.slurm
