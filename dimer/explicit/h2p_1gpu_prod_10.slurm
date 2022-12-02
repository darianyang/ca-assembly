#!/bin/bash
#SBATCH --job-name=v00_4xfx_sep_PROD_10
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=1 
#SBATCH --cluster=gpu
#SBATCH --gres=gpu:1
#SBATCH --partition=a100 
#SBATCH --time=120:00:00 
#SBATCH --mail-user=dty7@pitt.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --output=slurm_prod_10.out 
#SBATCH --error=slurm_prod_10.err 

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
INP=10_prod_rest.in
TOP=4xfx_sep_solv.prmtop
CRD=09_prod.rst
OUT=10_prod

$SANDER  -O     -i   $INP   -p   $TOP   -c   $CRD   -r   $OUT.rst \
        -o   $OUT.out   -e   $OUT.ene   -v   $OUT.vel   -inf $OUT.nfo   -x   $OUT.nc &&

# make cpptraj input file
echo "parm 4xfx_sep_solv.prmtop"                            > strip_10.in
echo "trajin 10_prod.nc"                                    >> strip_10.in
echo "unwrap :1-462"                                        >> strip_10.in
echo "center :1-462 mass origin"                            >> strip_10.in
echo "image origin center familiar"                         >> strip_10.in
echo "strip :WAT,Na+,Cl-"                                   >> strip_10.in
echo "trajout 10_prod_dry.nc"                               >> strip_10.in
echo "go"                                                   >> strip_10.in
echo "quit"                                                 >> strip_10.in

# run cpptraj to strip water
cpptraj -i strip_10.in > strip_10.out

# remove solvated nc file
#if [ -f "10_prod_dry.nc" ] ; then
#    rm 10_prod.nc &&
#    mv 10_prod_dry.nc 10_prod.nc
#fi

