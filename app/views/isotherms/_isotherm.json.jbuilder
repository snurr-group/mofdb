json.extract! isotherm, :id, :doi, :digitizer, :simin
json.adsorbates isotherm.gases.uniq
json.date isotherm.created_at.strftime("%Y-%M-%d")
json.temperature isotherm.temp
json.forcefield isotherm.forcefield.name
json.adsorbent do
  json.id isotherm.mof.id
  json.name isotherm.mof.name
end
json.category "exp"

json.adsorption_units Classification.find(isotherm.adsorption_units_id).name
json.pressure_units Classification.find(isotherm.pressure_units_id).name
json.composition_type Classification.find(isotherm.composition_type_id).name

points = {}
isotherm.isodata.each do |isodata|
  pressure = isodata.pressure
  subpoint = {'InChIKey': Gas.find(isodata.gas_id).inchikey, 'composition': isodata.bulk_composition, 'adsorption': isodata.loading}
  if !points.key?(pressure)
    points[pressure] = {}
    points[pressure]['total_adsorption'] = 0.0
  end
  points[pressure]['total_adsorption'] += isodata.loading

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
    json.inchikey subpoint[:InChIKey]
    json.name Gas.find_by(inchikey: subpoint[:InChIKey]).name

    json.composition subpoint[:composition]
    json.adsorption subpoint[:adsorption]
  end
end