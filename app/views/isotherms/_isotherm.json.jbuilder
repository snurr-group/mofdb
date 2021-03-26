json.extract! isotherm, :id, :digitizer, :simin
json.DOI isotherm.doi
json.batch_number isotherm.batch.nil? ? nil : isotherm.batch.id
json.adsorbates isotherm.gases.uniq.map{|g| g.to_nist_json}
json.date isotherm.created_at.strftime("%Y-%M-%d")
json.temperature isotherm.temp
json.adsorbent_forcefield isotherm.adsorbate_forcefield.name
json.molecule_forcefield isotherm.molecule_forcefield.name
json.adsorbent do
  json.id isotherm.mof.id
  json.name isotherm.mof.name
end
json.category "exp"

json.adsorptionUnits isotherm.adsorption_units.name
json.pressureUnits isotherm.pressure_units.name
json.compositionType isotherm.composition_type.name

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