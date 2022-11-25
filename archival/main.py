import os.path
import subprocess
import pathlib
import mofdb_client
import requests

def write_if_changed(expected_content, path):
    if os.path.exists(path):
        with open(path) as file:
            if file.read() == expected_content:
                return False
    with open(path, "w+") as file:
        file.write(expected_content)
        return True


directory = pathlib.Path(__file__).parent.resolve()
mofs_dir = os.path.join(directory, "mofdbx-archive", "mofs")

count = 1
updates = 0
for mof in mofdb_client.fetch():
    if count % 25 == 0:
        print(f"{count} out of ~170,000. {updates} updates thus far.", flush=True)
    count += 1
    mof_path = os.path.join(mofs_dir, f"{mof.name}.json")
    if write_if_changed(str(mof.json_repr), mof_path):
        updates += 1

print("f{updates} mof(s) where updated")
if updates != 0:
    print(f"Switching CWD to {mofs_dir}")
    # Switch CWD to ./mofdb-x-archive/mofs to make sure we commit in the archive repo not the mofdb repo
    os.chdir(mofs_dir)
    print("Running: `git add .`")
    subprocess.run(["git", "add", "."])
    print(f"Running `git commit -m \"Updated {updates} mofs\"")
    subprocess.run(["git", "commit", "-m", f"Updated {updates} mofs"])
    print(f"Running `git push`")
    subprocess.run(["git", "push"])
