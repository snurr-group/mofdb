
require 'faker'

FactoryBot.define do
  factory :mof do
    hashkey { rand(1000000) }
    name { Faker::Science::scientist }
    database { Database.all[rand(Database.all.length)-1] }
    cif { "path/to/cif" }
    void_fraction { rand(100).to_f/100 }
    surface_area_m2g { rand(5000) }
    surface_area_m2cm3 { rand(5000) }
    pld { rand(20) }
    lcd { rand(100) }
    pxrd { "aSDFASDFASDFASDFASDF" }
    pore_size_distribution { "asdfasdfasdfasdfasdf" }
  end
end

FactoryBot.define do
  factory :isotherm do
    doi { Faker::Alphanumeric.alpha 20 }
    digitizer { Faker::Science::scientist  }
    temp { rand(200) }
    simin { Faker::Lorem.paragraph }
    forcefield { Forcefield.all[rand(Forcefield.all.count)-1] }
    mof { Mof.all[rand(Mof.all.count)-1] }
    adsorption_units_id { Classification.all[rand(Classification.all.count)-1].id }
    pressure_units_id { Classification.all[rand(Classification.all.count)-1].id }
    composition_type_id { Classification.all[rand(Classification.all.count)-1].id }
  end
end


FactoryBot.define do

  factory :isodatum do

    isotherm { Isotherm.all[rand(Isotherm.all.count)-1] }
    gas { [Gas.find_by(name: "Nitrogen"), Gas.find_by(name: "Water"), Gas.find_by(name: "Carbon Dioxide")][rand(2)] }
    pressure { [0,10,20][rand(2)] }
    loading { rand(1000) }
    bulk_composition { rand(100).to_f/100 }

  end
end



