#!/bin/bash
#SBATCH --job-name=igb8_4xfx_sep_PROD_06
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=2
#SBATCH --gres=gpu:2
#SBATCH --cluster=invest 
#SBATCH --partition=lchong 
#SBATCH --time=144:00:00 
#SBATCH --mail-user=dty7@pitt.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --output=slurm_prod_06.out 
#SBATCH --error=slurm_prod_06.err 

# load appropriate modules.  First purge all modules then load in intel (a prereq for loading in amber) and then amber 
module purge
#module load intel/2017.3.196
#module load amber/18

module load gcc/8.2.0
module load openmpi/4.0.3
module load amber/22

# echo commands to stdout
set -x

export DO_PARALLEL="mpirun -np 2"
# Executable
SANDER=pmemd.cuda.MPI

# Amber input files and output name
INP=06_prod_rest.in
#TOP=4xfx_sep_imp.prmtop
TOP=4xfx_sep_igb8.prmtop
CRD=05_eq3.rst
OUT=06_prod

$DO_PARALLEL $SANDER  -O     -i   $INP   -p   $TOP   -c   $CRD   -r   $OUT.rst \
        -o   $OUT.out   -e   $OUT.ene   -v   $OUT.vel   -inf $OUT.nfo   -x   $OUT.nc

## make cpptraj input file
#echo "parm 4xfx_sep_solv.prmtop"                            > strip_06.in
#echo "trajin 06_prod.nc 1 last 10i"                                    >> strip_06.in
#echo "autoimage"                                            >> strip_06.in
#echo "strip :WAT,Cl-,Na+ parmout 4xfx_sep_dry.prmtop"           >> strip_06.in
#echo "trajout 06_prod_dry_10i.nc"                               >> strip_06.in
#echo "go"                                                   >> strip_06.in
#echo "quit"                                                 >> strip_06.in
#
## run cpptraj to strip water
#cpptraj -i strip_06.in > strip_06.out

# remove solvated nc file
#if [ -f "06_prod_dry.nc" ] ; then
#    rm 06_prod.nc &&
#    mv 06_prod_dry.nc 06_prod.nc
#fi

