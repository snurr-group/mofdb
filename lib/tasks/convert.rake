namespace :pregen do
  desc "Classifications that are convertable"
  task convert: :environment do
    cats = %w[cm3(STP)/g cm3(STP)/cm3 g/l mg/g mmol/g mol/kg cm3/cm3 atm bar kPa mbar mmHg MPa Pa psi Torr]
    cats.each do |load|
      cat = Classification.find_by(name: load)
      cat.convertable = true
      cat.save
    end

    loading =%w[cm3(STP)/g cm3(STP)/cm3 g/l mg/g mmol/g mol/kg cm3/cm3]

    pressure = %w[atm bar kPa mbar mmHg MPa Pa psi Torr]
    Classification.all.each do |clas|
      clas.source = "other"
      clas.convertable = false
      clas.save
    end
    loading.each do |load|
      load = Classification.find_by(name: load)
      load.convertable = true
      load.source = "loading"
      load.save
    end
    pressure.each do |load|
      load = Classification.find_by(name: load)
      load.convertable = true
      load.source = "pressure"
      load.save
    end
  end
end