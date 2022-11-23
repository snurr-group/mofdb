# Overview

The `main.py` script here will dump all mof's json
representations into `./mofdb-x-archive/mofs`. git add, 
commit, and push them to the repo.

mofdb-x-archive is a separate git repository (submodule of mofdb2) and you can find it here [github.com/snurr-group/mofdb-x-archive](https://github.com/snurr-group/mofdb-x-archive).

The purpose of this setup is to allow researcher to know exactly what
version of mofdb data another research used. This is important because 
mofdb data can change over time as new data is added,
corrections are made, etc.

# Requirements
`main.py` requires `python ^3.7` and is run weekly by cron.
It relies on one library `mofdb-client`.
