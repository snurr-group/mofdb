require 'base64'
require 'zip'
require 'set'
require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

namespace :datasets do
  desc "Generate all datasets for the databases page"
  task pregen: :environment do
    combinations = get_db_doi_gas_combos
    combinations. each do |db, doiToGas|
      gen_zip(db, nil, nil)
      doiToGas.keys.each do |doi|
        gen_zip(db, doi, nil)
        doiToGas[doi].each do |gases|
          puts "database: #{db.name} - doi:#{doi} - #{gases.to_a.map{|g|g.name}.join('/')}"
          gen_zip(db, doi, gases)
        end
      end
    end
  end
end

def gen_zip(db, doi, gases)
  # nil gas means generate a zip for the entire database/doi pair
  name = get_zip_name(db, doi, gases)
  path = Rails.root.join(Rails.root.join("public", "Datasets"), name)
  gas_ids_set = gases.nil? ? nil : gases.map{|g|g.id}.to_set
  if doi.nil?
    mof_ids = Mof.where(database: db).pluck(:id)
  else
    mof_ids = Isotherm.includes(:mof).where("mofs.database_id = (?)", db.id).where(doi: doi).pluck('isotherms.mof_id')
  end

  mofs = Mof.where("mofs.id in (?)", mof_ids)
  total = mofs.count
  puts "Total: #{total}"
  i = 0
  failures = 0

  Zip::OutputStream.open(path) do |io|
    puts "Openning zip"
    mofs.find_each do |mof|
      i += 1
      puts i if i%1000 == 0
      begin
        jsn = mof.pregen_json
        if gases.nil?
          io.put_next_entry(mof.name + ".cif")
          io.write(mof.cif)
          io.put_next_entry(mof.name + ".json")
          io.write(jsn.to_json)
          next
        end
        isos = jsn["isotherms"].filter { |iso|
          iso["adsorbates"].map { |ads| Gas.find[ads["id"]] }.to_set == gas_ids_set }
        jsn["isotherms"] = isos
        io.put_next_entry(mof.name + ".cif")
        io.write(mof.cif)
        io.put_next_entry(mof.name + ".json")
        io.write(jsn.to_json)
        # skipping mofs w/o istherms
      rescue Exception => e
        puts e
        failures += 1
      end
    end
    puts "Failures #{failures}"
  end
end