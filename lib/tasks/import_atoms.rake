namespace :load do
  # Import all mofid/mofkey in /lib/assets/mofid/*.csv
  desc "Import all atom from cif files"
  task atoms: :environment do
    mofs = Mof.all.take(1000)
    total =  mofs.size
    suc = 0
    fail = 0
    mofs.each_with_index do |mof,i|
      puts "suc:fail #{suc}:#{fail} out of #{total}" if i%100 == 0
      mof.write_cif_to_file
      begin
      out = `#{Rails.root.join("lib","tasks","atoms.py")} #{Rails.root.join("/","tmp","id-"+mof.id.to_s+".cif")}`
      atoms = out.gsub("]","").gsub("[","").gsub("\n","").gsub("'","").gsub(" ","").split(",")
      atoms = atoms.map {|atom| Element.find_by(symbol: atom)}
      mof.elements = atoms
      suc += 1
      rescue
        fail += 1
      ensure
      mof.delete_cif
      end
    end
    puts "COMPLETE"
    puts "suc:fail #{suc}:#{fail} out of #{total}"
  end
end
