require_relative '../isotherms/isotherm_json_helper.rb'

# See app/models/mof.rb function get_json to call this
# we generate JSON in a lot of ways (not always to show as a view)


json.extract! mof, :id, :mofid, :mofkey, :hashkey, :name, :void_fraction, :surface_area_m2g, :surface_area_m2cm3, :pld, :lcd, :pxrd, :pore_size_distribution
json.database mof.database.name
json.batch_number mof.batch.nil? ? nil : mof.batch.id
json.elements mof.elements.map {|el| {symbol: el.symbol, name: el.name}}
json.cif mof.hidden ? nil : mof.cif

json.url mof_path(mof, format: :json)
json.adsorbates mof.gases.map { |g| g.to_nist_json }.uniq


json.heats(mof.isotherms.select{|i| i.is_heat }) do |heat|
  print_iso(json, heat, convert_pressure, nil)
end

json.isotherms(mof.isotherms.select{|i| !i.is_heat }) do |isotherm|
  print_iso(json, isotherm, convert_pressure, convert_loading)
end