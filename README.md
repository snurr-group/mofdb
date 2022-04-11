
# README

[![Build](https://github.com/snurr-group/mofdb/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/snurr-group/mofdb2/actions)

This is the database + frontend for the MOF database of the Snurr Research Group at Northwestern university. The website aims to make high throughput simulation data easily searchable and reproducible. The isotherm format used here is compatiblle with the one used by the [NIST adsorption database](https://adsorption.nist.gov/). However, the schema used here has additional fields that are specific to simualted results. 
[mof.tech.northwestern.edu](https://mof.tech.northwestern.edu)

# Citation

If you use this work please cite the MofDB publication.
https://pubs.acs.org/doi/abs/10.1021/acs.cgd.9b01050

# Current Developer:
Nate Tracy-Amoroso (Northwestern University)
[github.com/n8ta](https://github.com/n8ta) [n8ta.com](https://n8ta.com)

# Future Developers:

If someone other than myself needs to do future development on this website here's information that will be helpful.

This repository is only part of mofdb. Another part is mofdb-interface, a python class that can be used to easily parse
raspa/zeo++ output and upload them to mofdb. That interface can be [found here](https://github.com/snurr-group/mofdb-interface).
The interface parses each mofs raspa output / pore calculations / void fraction and makes a post request to the server
at the /mofs/upload route with the APIKEY value set to the secret key (this is stored in the .env file on the production server as well
as in the PRIVATE repo for the interface). This key is the same for all users and should be kept within the group.

Next the server ```app/controllers/mofs_controller.rb``` parses the post request determines if that MOF already exists, if it does it 
returns the id of that mof, if not it creates a new mof. (mofs are identified by a sha256 hash of the cif). Then if there are isotherms accompanying 
the mof the interface will make a post to /isotherms/upload (apikey still set) with the isodata data. The server 
```app/controllers/isotherms_controller.rb``` will create the isotherm (automatically checking for and removing duplicates)
and then return a 200 response.   

Another piece of mofdb is the [mofdb_client python3 package](https://github.com/n8ta/mofdb-client) that wraps the API and can be used by anyone to access mofdb easily.

So that's the general structure, best of luck future developer. I've done my best to make the code clear and follow 
rails conventions to make your life easier. 
I'd recommend starting by looking at ```db/schema.rb``` and then [the api routes](https://mof.tech.northwestern.edu/api).

\- Nate

# Test Suite

There is a fairly comprehensive test suite in `spec/suites/*` run it with `bundle exec rspec spec/suites/*`.
It tests all api params except bulk/cif and exercises a bit of the ui.

# Maintenance Mode

You can turn on maintenance mode by creating the file `tmp/down.txt` with whatever message you want to show. This is helpful if you
want to be sure no one sees bad data while you are in the process of uploading.

If you need to use mofdb while it's in maintenance mode just go to `/down?bypass` and you'll be able to access the site.
To disable the bypass just go to `/down?end_bypass`.  
All /upload routes are still live in maintenance mode as are all json routes (the uploading tools use them to validate data).

Just the html front end is disabled.

# Rake tasks

## Pregen all
Regenerate all json for every mof and all zip files on the databases page. This should be run after uploading new data.
```> bundle exec rake environment pregen:all```

### Pregen datasets page (subset of pregen all)
```
> cd /var/www/sites/mof
> bundle exec rake environment pregen:databases
```

This job generates all the zip files for each combination of database-doi-gas you see in the databases page. This needs to be run 
each time that data changes. 

### Pregen json (subset of pregen all)

```
> cd /var/www/sites/mof
> bundle exec rake environment pregen:json
```

This job generates all the json shown on the site. Use this if those values are not appearing for some reason. You likely won't need to run this.
