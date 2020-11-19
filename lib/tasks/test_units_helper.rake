supported = ["cm3/cm3", "cm3(STP)/g", "g/l", "mg/g", "mmol/g", "mol/kg"] #, "wt%" ]


data = {
    "mol/kg": 1.8479585297,
    "mg/g": 51.7676014765,
    "cm3(STP)/g": 41.4200976677,
    "cm3(STP)/cm3": 64.2449106817,
}


debgia_clean = {
    "cm3(STP)/g": 141.1464124918,
    "mg/g": 176.4073877934,
    "cm3(STP)/cm3": 185.0725363292,
    "mol/kg": 6.2972501658,
}


namespace :testing do
  desc "Test the unit conversion library"
  task units: :environment do
    gas = Gas.find_by(formula: "N2")
    mof = Mof.find_by(name: "DEBGIA_clean")
    # puts "mol/kg to -> mg/g"
    # newValue = ApplicationController.helpers.convert_adsorption_units(
    #     "mol/kg", "mg/g", 1.8479585297, gas, mof, 80, 10)
    # puts "DIFF: #{newValue - 51.7676014765}"
    #
    # puts "\n\nBAD\n\n"
    # puts "mol/kg to -> cm3(STP)/g"
    # newValue = ApplicationController.helpers.convert_adsorption_units(
    #     "mol/kg", "cm3(STP)/g", 1.8479585297, gas, mof, 80, 10)
    #
    # puts "DIFF: #{newValue - 41.4200976677}"

    {"mg/g": 176.4073877934, "cm3(STP)/g": 141.1464124918}.each do  |unit1, val1|
      {"cm3(STP)/g": 141.1464124918, "mg/g": 176.4073877934 }.each do |unit2,  val2|
        newValue = ApplicationController.helpers.convert_adsorption_units(unit1.to_s, unit2.to_s, val1, gas, mof, 80, 10)
        diff = newValue - val2
        puts "\e[31mFrom #{unit1} to #{unit2}\e[0m diff is : #{diff}" if diff.abs > 0.1
        puts "From #{unit1} to #{unit2} diff is : #{diff}" if diff.abs < 0.1
        puts ""
      end
    end
  end
end


