"""
Compute radius of gyration using MDTraj.
"""

import mdtraj as md

pdb = "4xfx_leap"
t = md.load(f"{pdb}.pdb", top=f"{pdb}.pdb")

#top = t.topology
#prot = top.select("protein")

rog = md.compute_rg(t)
print(rog)
