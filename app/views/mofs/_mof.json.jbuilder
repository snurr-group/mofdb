json.extract! mof, :id, :mofid, :mofkey, :hashkey, :name, :void_fraction, :surface_area_m2g, :surface_area_m2cm3, :pld, :lcd, :pxrd, :pore_size_distribution
json.database mof.database.name

json.cif mof.hidden ? nil : mof.cif

gases = mof.gases.uniq

json.url mof_url(mof, format: :json)
json.adsorbates gases.uniq.map { |g| g.to_nist_json }

# json.heats(mof.heats) do |heat|
#   json.pressure heat.pressure
#   json.value heat.value
#   json.pressure_units Classification.find(heat.pressure_units_ids).name
#   json.value_units Classification.find(heat.value_units_id).name
# end

json.isotherms(mof.isotherms.select{|i| i.id == 1362520}) do |isotherm|
# json.isotherms(mof.isotherms.select{|i| i.gases.include?(Gas.find_by(name:"Methane"))}) do |isotherm|

  json.adsorbates isotherm.gases.uniq.map { |g| g.to_nist_json }

  json.extract! isotherm, :id, :digitizer, :simin
  json.DOI isotherm.doi
  json.date isotherm.created_at.strftime("%Y-%M-%d")
  json.temperature isotherm.temp
  json.adsorbate_forcefield isotherm.adsorbate_forcefield.name
  json.molecule_forcefield isotherm.molecule_forcefield.name
  json.adsorbent do
    json.id isotherm.mof.id
    json.name isotherm.mof.name
  end
  json.category "exp"




  isothermaAdsorptionUnits = Classification.find(isotherm.adsorption_units_id).name

  convertThisIsotherm = @convert && supportedUnits.include?(isothermaAdsorptionUnits)

  adsUnitsName = convertThisIsotherm  ? session[:prefUnits] : isothermaAdsorptionUnits
  json.adsorptionUnits adsUnitsName
  json.pressureUnits Classification.find(isotherm.pressure_units_id).name
  json.compositionType Classification.find(isotherm.composition_type_id).name

  points = {}
  isotherm.isodata.each do |isodata|
    pressure = isodata.pressure
    loading = convertThisIsotherm ? convert_adsorption_units(isothermaAdsorptionUnits, session[:prefUnits], isodata) : isodata.loading
    subpoint = {'InChIKey': Gas.find(isodata.gas_id).inchikey,
                'composition': isodata.bulk_composition,
                'adsorption': loading}
    if !points.key?(pressure)
      points[pressure] = {}
      points[pressure]['total_adsorption'] = 0.0
    end
    points[pressure]['total_adsorption'] += loading

    if points[pressure]['entries']
      points[pressure]['entries'] << subpoint
    else
      points[pressure]['entries'] = [subpoint]
    end
  end

  json.isotherm_data(points) do |pressure, point|
    json.pressure pressure
    json.total_adsorption point['total_adsorption']
    json.species_data(point['entries']) do |subpoint|
      json.InChIKey subpoint[:InChIKey]
      json.name Gas.find_by(inchikey: subpoint[:InChIKey]).name
      json.composition subpoint[:composition]
      json.adsorption subpoint[:adsorption]
    end
  end
  json.isotherm_url "/isotherms/" + isotherm.id.to_s + ".json"
end