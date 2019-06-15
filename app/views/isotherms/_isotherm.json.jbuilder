json.extract! isotherm, :id, :doi, :digitizer, :temp, :simin
json.forcefield isotherm.forcefield.name

json.url isotherm_url(isotherm, format: :json)

json.mof isotherm.mof
json.mof_url mof_path(isotherm.mof)
json.adsorption_units isotherm.adsorption_units
json.pressure_units isotherm.pressure_units
json.composition_type isotherm.composition_type
