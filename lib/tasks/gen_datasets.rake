require 'base64'
require 'zip'

namespace :datasets do
  desc "Generate all datasets for the databases page"
  task pregen: :environment do
    combinations = Rails.cache.read("combinations")
    combinations.each do |db, doiToGas|
      doiToGas.keys.each do |doi|
        doiToGas[doi].each do |gas|
          puts db.name
          puts doi
          puts gas.name
          gen_zip(db, doi, gas)


        end
      end
    end
  end
end

def gen_zip(db, doi, gas)
  puts ""
  name = "#{db.name}-#{doi}-#{gas.name}".gsub(/[^0-9a-z ]/i, ' ')+".zip"
  path = Rails.root.join(Rails.root.join("public"), name)

  mof_ids = gas.isodata.distinct.includes(:isotherm).where("isotherms.doi = (?)", doi).pluck('isotherms.mof_id')

  mofs = Mof.where("mofs.id in (?)", mof_ids)
  total = mofs.count
  puts "Total: #{total}"
  i = 0

  Zip::OutputStream.open(path) do |io|
    mofs.find_in_batches do |batch|
      batch.each do |mof|
        i += 1
        puts "#{i} / #{total}" if i % 1000 == 0
        io.put_next_entry(mof.name + ".json")
        io.put_next_entry(mof.name + ".cif")
        io.write(mof.cif)
        io.write(mof.pregen_json.to_s)
      end
    end
  end
end