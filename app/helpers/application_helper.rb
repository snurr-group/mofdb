require 'set'

module ApplicationHelper

  RESULTS = {
    :success => 'success',
    :error => 'error',
  }

  def get_version
    Rails.cache.fetch("mofdb-version-v4", expires_in: 1.second) do
      archive = Rails.root.join("archival", "mofdbx-archive")
      res = Dir.chdir archive do
        %x(git rev-parse --short HEAD)
      end
      res.strip # Remove trailing \n
    end
  end

  def get_zip_name(db, doi, gases)
    version = get_version
    path = if doi.nil?
             db.name.gsub(/[^0-9a-z ]/i, ' ')

           else
             doi_clean = doi.doi.gsub(/[^0-9a-z ]/i, ' ')
             gas_section = gases.nil? ? "all" : gases.to_a.map { |g| g.name }.join("-")
             path = "#{db.name}-#{doi_clean}-#{gas_section}"
             path.gsub(/[^0-9a-z -]/i, ' ')
           end
    path + "-mofdb-version:#{version}.zip"
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
    expiry = Rails.env.test? ? 0.days : 3.days
    Rails.cache.fetch("combinations", expires_in: expiry) do
      combinations = {}
      Database.all.each do |db|
        combinations[db] = {}
        # Find all dois in the db
        dois = db.mofs.joins(:isotherms).joins(:dois).select("dois.id").distinct.pluck("dois.id").map { |i| Doi.find(i) }
        dois.each do |doi|
          gases = Set.new
          query = "SELECT DISTINCT JSON_OBJECTAGG(isodata.gas_id,'') from isotherms
                  INNER JOIN isodata on isodata.isotherm_id = isotherms.id
                  INNER JOIN mofs on isotherms.mof_id = mofs.id
                  WHERE isotherms.doi_id = (?) and mofs.database_id = (?)
                  GROUP BY  isotherms.id;"

          sanitized = ActiveRecord::Base.send(:sanitize_sql_array, [query, doi.id, db.id])
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
