"""
Compute radius of gyration using MDTraj.
"""

import mdtraj as md

pdb = "models/model_1_fixer"
t = md.load(f"{pdb}.pdb", top=f"{pdb}.pdb")

#top = t.topology
#prot = top.select("protein")

rog = md.compute_rg(t)
print(rog)
