module ApplicationHelper

  def get_db_doi_gas_combos
    combinations = Rails.cache.read("combinations")
    if (combinations.nil?)
      puts "CACHE MISS"
      combinations = {}
      all_dois = Isotherm.distinct.pluck(:doi).uniq.select { |doi| !doi.nil? }
      Database.all.each do |db|
        combinations[db] = {}
        dois = all_dois.select { |doi| Isotherm.find_by(doi: doi).mof.database == db }
        dois.each do |doi|
          combinations[db][doi] = []
          gases = Isotherm.distinct.where(doi: doi).includes(:isodata).pluck("isodata.gas_id")
          gases = gases.select { |gas_id| !gas_id.nil? }.map { |gas_id| Gas.find(gas_id) }
          combinations[db][doi] = gases
        end
      end
      Rails.cache.write('combinations', @combinations, expires_in: 30.days)
    else
      puts "CACHE HIT"
    end
    return combinations
  end
end
