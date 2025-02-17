from pdbfixer import PDBFixer
from openmm.app import PDBFile

import subprocess

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
#pdb_fix('4xfx')

# run pdb4amber (ambertools must be installed)
# --no-conect will not write connect records for disulfide bonds (e.g. for reducing conditions)
#subprocess.run(['pdb4amber', '--no-conect', '-i', '4xfx_fixer.pdb', '-o', '4xfx_leap.pdb'])

# TODO: maybe remove the extra output files from pdb4amber

# make 20Å separated monomers into amber compatible format (2 models, -1 = all models)
subprocess.run(['pdb4amber', '--no-conect', '-i', '4xfx_sep20A.pdb', '-o', '4xfx_sep20A_leap.pdb', '--model', '-1'])
