json.extract! isotherm, :id, :doi, :digitizer, :simin
json.adsorbates isotherm.gases.uniq.map{|g| g.to_nist_json}
json.date isotherm.created_at.strftime("%Y-%M-%d")
json.temperature isotherm.temp
json.adsorbate_forcefield isotherm.adsorbate_forcefield.name
json.molecule_forcefield isotherm.molecule_forcefield.name
json.adsorbent do
  json.id isotherm.mof.id
  json.name isotherm.mof.name
end
json.category "exp"

json.adsorptionUnits Classification.find(isotherm.adsorption_units_id).name
json.pressureUnits Classification.find(isotherm.pressure_units_id).name
json.compositionType Classification.find(isotherm.composition_type_id).name

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
    json.InChIKey subpoint[:InChIKey]
    json.name Gas.find_by(inchikey: subpoint[:InChIKey]).name

    json.composition subpoint[:composition]
    json.adsorption subpoint[:adsorption]
  end
end