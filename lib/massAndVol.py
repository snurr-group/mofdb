from ase.io import read
import sys
import json
mof = read(sys.argv[1])
mass = sum(mof.get_masses())
vol = mof.get_volume()
obj = {'atomicMass': mass, 'volumeA3': vol}
print(json.dumps(obj))