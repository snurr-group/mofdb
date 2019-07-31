require 'CSV'

def parse_elements(path_to_cif)

end
#     cf = ReadCif(path_to_cif)
# atoms = cf[cf.visible_keys[0]]["_atom_site_label"]
# j = 0
# while j < len(atoms):
#   atoms[j] = ''.join([i for i in atoms[j] if not i.isdigit()])
#   j = j + 1
#   atoms_no_dupes = []
# 
#   for x in atoms:
#     if x == "C1":
#         y = 2
#     if x not in atoms_no_dupes:
#         atoms_no_dupes.append(x)
#     return atoms_no_dupes



namespace :import do
  desc "Import from csv file"
  task csv: :environment do


    # mofdb.csv_upload(,
    #                  "/Users/n8ta/code/mofdb-interface/__ARCHIVAL_DATA__/hMOF/")


    cifs = "/Users/n8ta/code/mofdb-interface/__ARCHIVAL_DATA__/hMOF/"
    csv = CSV.new(open("/Users/n8ta/code/mofdb-interface/__ARCHIVAL_DATA__/CSVs/hMOFs-methane.csv",'r'), headers: true)
    puts "csv:"
    puts csv.inspect
    csv.each do |row|
      # puts row.inspect
      file_name = row["cif_name"]
      file_name = file_name + ".cif" if file_name[-3, -0] != ".cif"
      file = open(Rails.root.join(cifs, file_name), 'r')
      hashkey = Digest::SHA256.hexdigest(file.read())
      hashkey = hashkey[0,50]


      parse_elements(Rails.root.join(cifs, file_name))



    end

  end
end
