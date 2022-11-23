import os.path
import subprocess
import pathlib
import mofdb_client


def write_if_changed(expected_content, path):
    if os.path.exists(path):
        with open(path) as file:
            if file.read() == expected_content:
                return False
    with open(path, "w+") as file:
        file.truncate(0)
        file.write(expected_content)
        return True


directory = pathlib.Path(__file__).parent.resolve()
mofs_dir = os.path.join(directory, "mofdb-x-archive", "mofs")

count = 1
updates = 0
for mof in mofdb_client.fetch():
    if count % 25 == 0:
        print(f"{count} out of 168,000")
    count += 1
    if write_if_changed(str(mof.json_repr), os.path.join(mofs_dir, f"{mof.name}.json")):
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

