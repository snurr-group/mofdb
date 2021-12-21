from ase.io import read
import sys
import json
import pymatgen.io.cif as pmcif
from pymatgen.core import Structure
import os

mof_file = sys.argv[1]

def read_mof(mof_path, attempt):
# path: cif to open
# attempt: debug info so we know which attempt worked
    try:
        mof = read(mof_path)
        mass = sum(mof.get_masses())
        vol = mof.get_volume()
        return {'success': True, 'attempt': attempt, 'atomicMass': mass, 'volumeA3': vol}
    except Exception:
        return {'success': False, 'attempt': attempt}

res = read_mof(mof_file, 0)
if res['success']:
    print(json.dumps(res))
    sys.exit(0)

exit_code = -1
new_cif_path = mof_file+".2.cif"
try:
    # Convert read cif into pymatgen to try and standardized it
    struct = Structure.from_file(mof_file, primitive=False)
    sc_cif = pmcif.CifWriter(struct)
    sc_cif.write_file(new_cif_path)

    # Try reading vol/mass again
    res = read_mof(new_cif_path,1)
    # If this second attempt fails, nothing we can do. Just pass on the failure
    print(json.dumps(res))
    if (res['success']):
        exit_code = 0
finally:
    # remove this temp file
    os.remove(new_cif_path)

sys.exit(exit_code)
