require 'set'

module ApplicationHelper

  def fetch_or_gen(key, lambda, expiry = nil)
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
    return "#{db.name}-#{doi}-#{gases.nil? ? "all" : gases.to_a.map { |g| g.name }.join("-")}".gsub(/[^0-9a-z ]/i, ' ') + ".zip"
  end

  def get_db_doi_gas_combos
    Rails.cache.fetch("combinations") do
      combinations = {}
      all_dois = Isotherm.distinct.pluck(:doi).uniq.select { |doi| !doi.nil? }
      Database.all.each do |db|
        combinations[db] = {}
        dois = all_dois.select { |doi| Isotherm.find_by(doi: doi).mof.database == db }
        dois.each do |doi|
          gases = Set[]
          query = "SELECT DISTINCT JSON_OBJECTAGG(isodata.gas_id,'') from isotherms
                   INNER JOIN isodata on isodata.isotherm_id = isotherms.id
                   WHERE doi = (?)
                   GROUP BY  isotherms.id;"
          sanitized = ActiveRecord::Base.send(:sanitize_sql_array, [query, doi])
          results = ActiveRecord::Base.connection.execute(sanitized)
          results.each do |result|
            new = JSON.parse(result[0]).keys.map { |v| Gas.find(v.to_i) }.to_set
            gases << new
          end
          combinations[db][doi] = gases
        end
      end
      combinations
    end
  end
end
