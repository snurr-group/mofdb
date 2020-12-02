supported = ["cm3/cm3", "cm3(STP)/g", "g/l", "mg/g", "mmol/g", "mol/kg"] #, "wt%" ]


mofs = [
    {
        name: "abeful_clean",
        temp: 80,
        pressure: 80000,
        units: {
            "mol/kg": 3.3443882212,
            "mg/g": 93.6876849967,
            "cm3(STP)/g": 74.9610364813,
            "cm3(STP)/cm3": 116.2688010053,
        }
    },
    {
        name: "abeful_clean",
        temp: 80,
        pressure: 10,
        units: {
            "mol/kg": 1.8479585297,
            "mg/g": 51.7676014765,
            "cm3(STP)/g": 41.4200976677,
            "cm3(STP)/cm3": 64.2449106817,
        }
    },
    {
        name: "debgia_clean",
        temp: 80,
        pressure: 10,
        units: {
            "cm3(STP)/g": 141.1464124918,
            "mg/g": 176.4073877934,
            "cm3(STP)/cm3": 185.0725363292,
            "mol/kg": 6.2972501658,
        }
    }
]

namespace :testing do
  desc "Test the unit conversion library"
  task units: :environment do
    mofs.each do |data|

      gas = Gas.find_by(formula: "N2")
      mof = Mof.find_by(name: data[:name])

      data[:units].each do |unit1, val1|
        data[:units].each do |unit2, val2|
          newValue = ApplicationController.helpers.convert_adsorption_units_wrapped(unit1.to_s, unit2.to_s, val1, gas, mof, data[:temp], data[:pressure])
          diff = newValue - val2
          percentageDiff = (diff / newValue * 100)
          puts "\e[31mFrom #{unit1} to #{unit2}\e[0m Expected: #{val2} got #{newValue} diff is : #{percentageDiff}%" if percentageDiff.abs > 0.01
        end
      end
    end

    puts "TEST COMPLETE"

  end
end


