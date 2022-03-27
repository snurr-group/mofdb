def print_iso(json, # jbuilder json rendering object
              isotherm, # isotherm itself
              convert_pressure, # nil or Classification.rb
              convert_loading)
  # nil or Classification.rb

  mof = isotherm.mof
  json.batch_number isotherm.batch.nil? ? nil : isotherm.batch.id
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

  can_convert_pressure = !convert_pressure.nil? && convert_pressure.convertable &&
    isotherm.pressure_units.convertable && mof.convertable
  can_convert_loading = !convert_loading.nil? && convert_loading.convertable &&
    isotherm.adsorption_units.convertable && mof.convertable

  json.adsorptionUnits can_convert_loading ? convert_loading.name : isotherm.adsorption_units.name
  json.pressureUnits can_convert_pressure ? convert_pressure.name : isotherm.pressure_units.name

  json.compositionType isotherm.composition_type.name

  points = isotherm.points(can_convert_pressure, can_convert_loading,
                           convert_pressure, convert_loading)

  json.isotherm_data(points) do |pressure, point|
    json.pressure pressure
    json.total_adsorption point['total_adsorption']
    json.species_data(point['entries']) do |subpoint|
      json.InChIKey subpoint[:inchikey]
      json.name subpoint[:gas_name]
      json.composition subpoint[:composition]
      json.adsorption subpoint[:adsorption]
    end
  end

  json.isotherm_url "/isotherms/" + isotherm.id.to_s + ".json"
end