class AddToGas < ActiveRecord::Migration[6.0]
  def change
    add_column :gases, :molarMass, :float

    n2 = Gas.find_by(formula: "N2")
    xe = Gas.find_by(formula: "Xe")
    kr = Gas.find_by(formula: "Kr")
    h2 = Gas.find_by(formula: "H2")
    co2 = Gas.find_by(formula: "CO2")
    ch4 = Gas.find_by(formula: "CH4")
    h20 = Gas.find_by(formula: "H2O")
    ar = Gas.find_by(formula: "Ar")

    n2.molarMass = 28.0134
    n2.save!
    xe.molarMass = 131.293
    xe.save!
    kr.molarMass = 83.798
    kr.save!
    h2.molarMass = 1.00794 * 2
    h2.save!
    co2.molarMass = 44.0095
    co2.save!
    ch4.molarMass = 16.04
    ch4.save!
    h20.molarMass = 18.01528
    h20.save!
    ar.molarMass = 39.948
    ar.save!

  end
end
