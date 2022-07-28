from pdbfixer import PDBFixer
from openmm.app import PDBFile

import subprocess
import sys

#pdb = 'models/model_1'
pdb = sys.argv[1]

def pdb_fix(pdb_prefix):
    '''
    Run PDBFixer.

    Parameters
    ----------
    pdb_prefix : str
        Path to input pdb file but without the .pdb
        e.g. if the pdb is named 'abc1.pdb', input 'abc1'.
    '''
    # initialize pdb fixer
    fixer = PDBFixer(filename=f'{pdb_prefix}.pdb')
 
    # run fixer methods
    fixer.findMissingResidues()
    fixer.findNonstandardResidues()
    print('Non-standard residues and replacments: ', fixer.nonstandardResidues)
    fixer.replaceNonstandardResidues()
    # remove crystallographic water (note some hetatoms may be needed)
    fixer.removeHeterogens(keepWater=False)
    fixer.findMissingAtoms()
    fixer.addMissingAtoms()
    fixer.addMissingHydrogens(7.0)

    # write out new pdb file (can use sys.stdout with no out file arg)
    PDBFile.writeFile(fixer.topology, fixer.positions, open(f'{pdb_prefix}_fixer.pdb', 'w'))

# run pdbfixer
#pdb_fix(pdb)

# run pdb4amber (ambertools must be installed)
# --no-conect will not write connect records for disulfide bonds (e.g. for reducing conditions)
# model -1 for all models (3 CA dimers in this case)
# sep2 was an attempt to make the system more compact
subprocess.run(['pdb4amber', '--no-conect', 
                '-i', f'{pdb}.pdb', 
                '-o', f'{pdb}_leap.pdb',
                '--model', '-1'])

