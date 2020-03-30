#! ./venv/bin/python

from CifFile import ReadCif
import sys

# I couldn't find a good way to read CIFs in ruby so we have to call this python script
# pip install PyCifRW

cf = ReadCif(sys.argv[1])
atoms = cf[cf.visible_keys[0]]["_atom_site_label"]
j = 0
while j < len(atoms):
    atoms[j] = ''.join([i for i in atoms[j] if not i.isdigit()])
    j = j + 1
atoms_no_dupes = []

for x in atoms:
    if x == "C1":
        y = 2
    if x not in atoms_no_dupes:
        atoms_no_dupes.append(x)
print(atoms_no_dupes)