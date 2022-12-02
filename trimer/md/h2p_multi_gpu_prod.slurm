#!/bin/bash
#SBATCH --job-name=tod_sep_PROD_06
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=1 
#SBATCH --cluster=gpu
#SBATCH --gres=gpu:1
#SBATCH --partition=a100
#SBATCH --time=144:00:00 
#SBATCH --mail-user=dty7@pitt.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --output=slurm_prod_06.out 
#SBATCH --error=slurm_prod_06.err 

module purge
module load gcc/8.2.0
module load openmpi/4.0.3
module load amber/22

# echo commands to stdout
set -x

# Executable
SANDER=pmemd.cuda

# Amber input files and output name
INP=06_prod_rest.in
TOP=2m8l_sep_solv.prmtop
CRD=05_eq3.rst
OUT=06_prod

$SANDER  -O     -i   $INP   -p   $TOP   -c   $CRD   -r   $OUT.rst \
        -o   $OUT.out   -e   $OUT.ene   -v   $OUT.vel   -inf $OUT.nfo   -x   $OUT.nc &&

# make cpptraj input file
echo "parm 2m8l_sep_solv.prmtop"                            > strip_06.in
echo "trajin 06_prod.nc"                                    >> strip_06.in
echo "autoimage"                                            >> strip_06.in
echo "strip :WAT,Cl-,Na+ parmout 2m8l_sep_dry.prmtop"       >> strip_06.in
echo "trajout 06_prod_dry.nc"                               >> strip_06.in
echo "go"                                                   >> strip_06.in
echo "quit"                                                 >> strip_06.in

# run cpptraj to strip water
#cpptraj -i strip_06.in > strip_06.out

###################################################
###################################################
###################################################
PDB="gb1_ntaco_solv" 
###################################################
###################################################
###################################################

# 10 ns pcs restrained NPT production Langevin thermostat (298K) MC barostat (1atm)
#printf "\nstart pcs restrained md\n\n" 
#$DO_PARALLEL \
#    $SANDER -O \
#            -i 06_prod.in -o 06_prod.out \
#            -p ${PDB}.prmtop -c 05_prod.rst -r 06_prod.rst &&
#printf "\ndone pcs restrained md\n\n"

for PROD in {14..15} ; do
    # keep leading zero but prevent octal interpretation, keep base10
    PREV=$(printf "%02d" $((10#$PROD - 1)))
    # 1 ns pcs restrained NPT production Langevin thermostat (298K) MC barostat (1atm)
    printf "\nstart $PROD prod pcs restrained md\n\n" 
    $DO_PARALLEL \
        $SANDER -O \
                -i ${PROD}_prod.in -o ${PROD}_prod.out \
                -p ${PDB}.prmtop -c ${PREV}_prod.rst -r ${PROD}_prod.rst &&
    printf "\ndone $PROD prod pcs restrained md\n\n"
done
