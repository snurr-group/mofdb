require 'base64'
require 'zip'

namespace :datasets do
  desc "Generate all datasets for the databases page"
  task pregen: :environment do
    combinations = ApplicationHelper.get_db_doi_gas_combos
    combinations.each do |db, doiToGas|
      doiToGas.keys.each do |doi|
        doiToGas[doi].each do |gas|
          puts db.name
          puts doi
          puts gas.name
          gen_zip(db, doi, gas)
        end
        gen_zip(db, doi, nil)
      end
    end
  end
end

def gen_zip(db, doi, gas)
  # nil gas means generate a zip for the entire database/doi pair
  puts ""
  name = "#{db.name}-#{doi}-#{gas.nil? ? "all" : gas.name}".gsub(/[^0-9a-z ]/i, ' ') + ".zip"
  path = Rails.root.join(Rails.root.join("public", "Datasets"), name)


  if gas.nil?
    mofs_ids = Isotherm.includes(:mof).where("mofs.database_id = (?)", db.id).where(doi: doi).pluck('isotherms.mof_id')
  else
    mof_ids = gas.isodata.distinct.includes(:isotherm).where("isotherms.doi = (?)", doi).pluck('isotherms.mof_id')
  end

  mofs = Mof.where("mofs.id in (?)", mof_ids)
  total = mofs.count
  puts "Total: #{total}"
  i = 0
  failures = 0

  Zip::OutputStream.open(path) do |io|
    puts "Openning zip"
    mofs.find_in_batches do |batch|
      batch.each do |mof|
        begin
          jsn = mof.pregen_json
          if gas.nil?
            io.put_next_entry(mof.name + ".cif")
            io.write(mof.cif)
            io.put_next_entry(mof.name + ".json")
            io.write(jsn.to_json)
            next
          end
          isos = jsn["isotherms"].filter { |iso|
            iso["adsorbates"].map { |ads| ads["id"] }.include?(gas.id) }
          jsn["isotherms"] = isos
          if isos.any?
            io.put_next_entry(mof.name + ".cif")
            io.write(mof.cif)
            io.put_next_entry(mof.name + ".json")
            io.write(jsn.to_json)
          else
            # skipping mofs w/o istherms
          end
        rescue Exception => e
          puts e
          failures += 1
        end
      end
    end
  end
  puts "Failures #{failures}"
end