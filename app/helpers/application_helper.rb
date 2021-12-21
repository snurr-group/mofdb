require 'set'

module ApplicationHelper

  def get_zip_name(db, doi, gases)
    if doi.nil?
      db.name.gsub(/[^0-9a-z ]/i, ' ') + '.zip'
    else
      gas_section = gases.nil? ? "all" : gases.to_a.map { |g| g.name }.join("-")
      path = "#{db.name}-#{doi}-#{gas_section}"
      path.gsub(/[^0-9a-z ]/i, ' ') + ".zip"
    end
  end

  def get_db_doi_gas_combos
    # This function is complicated.
    #
    # Here's what we want to generate
    # CoREMOF => {
    #   doi1: [ SET(methane), SET(xenon,krypton) ]
    #   doi2: [ SET(xenon)]
    # hMOF => ...
    #
    # DOIs are associated with a list of sets of gases.
    # This is because having isotherms with xenon and isotherms with krypton
    # is not the same as having xenon&krypton mutli-component isotherms.
    #
    # The reason we generate this nested hash of DB -> DOI -> LIST[Set[Gases]]
    # is so the database page can have a set of pre-create zip files for each combination.
    # Eg. There is a pre-generated hMOF + 10.1039/C2EE23201D + Nitrogen Zip file
    # that can be downloaded much faster than using the API.
    #
    # There is a rake task `pregen:all` that builds these zip files.
    #
    # Just be sure you know what this does before you edit it.
    #
    Rails.cache.fetch("combinations", expires_in: 3.days) do
      combinations = {}
      all_dois = Isotherm.distinct.pluck(:doi).uniq.select { |doi| !doi.nil? }
      Database.all.each do |db|
        combinations[db] = {}
        # Pick out the dois present on an isotherm in this database
        dois = all_dois.select { |doi| Isotherm.joins(:mof).where("mofs.database_id = ?", db.id).where("isotherms.doi = ?", doi).exists? }
        dois.each do |doi|
          gases = Set.new
          query = "SELECT DISTINCT JSON_OBJECTAGG(isodata.gas_id,'') from isotherms
                  INNER JOIN isodata on isodata.isotherm_id = isotherms.id
                  WHERE doi = (?)
                  GROUP BY  isotherms.id;"

          sanitized = ActiveRecord::Base.send(:sanitize_sql_array, [query, doi])
          results = ActiveRecord::Base.connection.execute(sanitized)
          results.each do |result|
            gases << JSON.parse(result[0]).keys.map { |v| Gas.find(v.to_i) }.to_set
          end
          combinations[db][doi] = gases
        end
      end
      combinations
    end
  end
end
