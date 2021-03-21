json.extract! mof, :id, :mofid, :mofkey, :hashkey, :name, :void_fraction, :surface_area_m2g, :surface_area_m2cm3, :pld, :lcd, :pxrd, :pore_size_distribution
json.database mof.database.name

json.cif mof.hidden ? nil : mof.cif

gases = mof.gases.uniq

json.url mof_url(mof, format: :json)
json.adsorbates gases.uniq.map { |g| g.to_nist_json }

json.isotherms(mof.isotherms) do |isotherm|

  json.adsorbates isotherm.gases.uniq.map { |g| g.to_nist_json }

  json.extract! isotherm, :id, :digitizer, :simin
  json.DOI isotherm.doi
  json.date isotherm.created_at.strftime("%Y-%M-%d")
  json.temperature isotherm.temp
  json.adsorbent_forcefield isotherm.adsorbate_forcefield.name
  json.molecule_forcefield isotherm.molecule_forcefield.name
  json.adsorbent do
    json.id isotherm.mof.id
    json.name isotherm.mof.name
  end
  json.category "exp"

  isothermAdsorptionUnits = isotherm.adsorption_units
  isothermPressureUnits = isotherm.pressure_units


  json.adsorptionUnits convert_loading ? convert_loading.name : isothermAdsorptionUnits.name
  json.pressureUnits convert_pressure ? convert_pressure.name : isothermPressureUnits.name
  json.compositionType isotherm.composition_type

  can_convert_pressure = !convert_pressure.nil? && convert_pressure.convertable && isotherm.pressure_units.convertable
  can_convert_loading = !convert_loading.nil? && convert_loading.convertable && isotherm.adsorption_units.convertable

  points = {}
  isotherm.isodata.each do |isodata|
    pressure = can_convert_pressure ?
                 convert_pressure_units(isodata, convert_pressure) :
                 isodata.pressure
    loading = can_convert_loading ?
                convert_adsorption_units(isotherm.adsorption_units, convert_loading, isodata) :
                isodata.loading
    subpoint = {'gas': isodata.gas,
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
      json.InChIKey subpoint[:gas].inchikey
      json.name subpoint[:gas].name
      json.composition subpoint[:composition]
      json.adsorption subpoint[:adsorption]
    end
  end
  json.isotherm_url "/isotherms/" + isotherm.id.to_s + ".json"
end