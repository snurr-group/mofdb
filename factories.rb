
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