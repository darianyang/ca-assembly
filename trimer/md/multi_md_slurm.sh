#!/bin/bash
# use this script to make multiple slurm submission files

PROD_IN=06_prod.in
PDB=2m8l_sep

# loop over and create multiple prod with slurm files
for PROD in {09..10} ; do
    # keep leading zero but prevent octal interpretation, keep base10
    PREV=$(printf "%02d" $((10#$PROD - 1)))
    NEXT=$(printf "%02d" $((10#$PROD + 1)))

    # var for input coordinate file
    # unique values for first prod run
    if [ $PROD == 06 ] ; then
        CRD=05_eq3.rst
        PARMOUT="parmout ${PDB}_dry.prmtop"
    else
        CRD=${PREV}_prod.rst
        PARMOUT=""
    fi 

    # make the prod md input file
    cp $PROD_IN ${PROD}_prod.in

# make the slurm submission file
cat << EOF > h2p_gpu_prod_${PROD}.slurm
#!/bin/bash
#SBATCH --job-name=tod_${PDB}_${PROD}
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=1
#SBATCH --cluster=gpu
#SBATCH --gres=gpu:1
#SBATCH --partition=a100
#SBATCH --time=144:00:00 
#SBATCH --mail-user=dty7@pitt.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --output=job_logs/slurm_prod_${PROD}.out 
#SBATCH --error=job_logs/slurm_prod_${PROD}.err 

module purge
module load gcc/8.2.0
module load openmpi/4.0.3
module load amber/22

# echo commands to stdout
set -x

# Executable
SANDER=pmemd.cuda

# NPT production
    \$SANDER -O \
            -i ${PROD}_prod.in -o ${PROD}_prod.out -x ${PROD}_prod.nc \
            -p ${PDB}_solv.prmtop -c $CRD -r ${PROD}_prod.rst -inf ${PROD}_prod.nfo &&

# make cpptraj input file
echo "parm PDB_TEMP_solv.prmtop"                            > strip/strip_${PROD}.in
echo "trajin ${PROD}_prod.nc"                               >> strip/strip_${PROD}.in

# fancy imaging
echo "unwrap :1-1386"                                       >> strip/strip_${PROD}.in
echo "center :1-1386 mass origin"                           >> strip/strip_${PROD}.in
echo "image origin center familiar"                         >> strip/strip_${PROD}.in

echo "strip/strip :WAT,Cl-,Na+ $PARMOUT"                    >> strip/strip_${PROD}.in
echo "trajout ${PROD}_prod_dry.nc"                          >> strip/strip_${PROD}.in
echo "go"                                                   >> strip/strip_${PROD}.in
echo "quit"                                                 >> strip/strip_${PROD}.in

# run cpptraj to strip water
cpptraj -i strip/strip_${PROD}.in > strip/strip_${PROD}.out

sbatch h2p_gpu_prod_${NEXT}.slurm
EOF


done
