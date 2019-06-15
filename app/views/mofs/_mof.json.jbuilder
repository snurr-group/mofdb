json.extract! mof, :id, :hashkey, :name, :cif, :void_fraction, :surface_area_m2g, :surface_area_m2cm3, :pld, :lcd, :pxrd, :pore_size_distribution
json.database mof.database.name

gases = []
mof.isotherms.each do |iso|
  gases.concat(iso.gases)
end
gases.uniq

json.url mof_url(mof, format: :json)
json.gases gases