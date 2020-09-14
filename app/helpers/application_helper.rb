require 'set'

module ApplicationHelper

  def fetch_or_gen(key, lambda, expiry=nil)
    val = Rails.cache.read(key)
    if val.nil?
      val = lambda.call
      Rails.cache.write(key, val, expires_in: expiry.nil? ? 1.days : expiry)
    end
    return val
  end

  def get_zip_name(db, doi, gases)
    if doi.nil?
      return db.name.gsub(/[^0-9a-z ]/i, ' ') + '.zip'
    end
    return "#{db.name}-#{doi}-#{gases.nil? ? "all" : gases.to_a.map{|g|Gas.find(g).name}.join("-")}".gsub(/[^0-9a-z ]/i, ' ') + ".zip"
  end

  def get_db_doi_gas_combos
    combinations = Rails.cache.read("combinations")
    # combinations = nil
    if (combinations.nil?)
      puts "CACHE MISS"
      combinations = {}
      all_dois = Isotherm.distinct.pluck(:doi).uniq.select { |doi| !doi.nil? }
      Database.all.each do |db|
        puts db.name
        combinations[db] = {}
        dois = all_dois.select { |doi| Isotherm.find_by(doi: doi).mof.database == db }
        dois.each do |doi|
          gases = Set[]
          count = 0
          Isotherm.distinct.where(doi: doi).includes(:gases).find_each(batch_size: 1000) do |iso|
            count += 1
            puts count if count%1000 == 0
            gases << iso.gases.pluck(:id).to_set
          end
          combinations[db][doi] = gases
        end
      end
      Rails.cache.write('combinations', combinations, expires_in: 30.days)
    else
      puts "CACHE HIT"
    end
    return combinations
  end
end
