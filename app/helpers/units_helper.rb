class UnsupportedGasUnit < StandardError
  def initialize(msg=nil)
    super
  end
end

module UnitsHelper

  def convert_molecule_unit(from, to, value, volumeA3, molarMass)
  end
  # temp = k
  # pressure = atm
  def convert_gas_unit(from, to, value, molarMass, tempK, pressureAtm)
    r = 0.082057
    supported = ["cm3", "cm3(STP)", "g", "mg", "mmol", "mol"]
    raise UnsupportedGasUnit("#{from} is not a supported gas unit") if supported.index(from).nil?
    raise UnsupportedGasUnit("#{to} is not a supported gas unit") if supported.index(to).nil?
    grams = nil

    # Convert everything into grams
    if from == "mg"
      grams = value / 1000.0
    elsif from == "mol"
      grams = value * molarMass
    elsif from == "g"
      grams = value
    elsif from == "cm3"
      liters = value / 1000.0
      moles = pressure * liters / (0.082057 * temp)
      grams = moles * molarMass
    elsif from == "cm3(STP)"
      cm3 = pressure * value * 275.15 / (temp * 1)
      liters = cm3 * 0.001
      moles = 1 * liters / (r * temp)
      grams = moles * molarMass
    elsif from == "mmol"
      grams = (value / 1000.0) * molarMass
    end

    # Convert grams into what we want
    if to == "mg"
      return grams * 1000.0
    elsif to == "mol"
      return grams / molarMass
    elsif to == "g"
      return grams
    elsif to == "cm3"
      moles = grams / molarMass
      return (moles * r * temp * 1000.0) / pressure
    elsif to == "cm3(STP)"
      moles = grams / molarMass
      return moles * r * 275.15 * 1000.0
    elsif to == "mmol"
      return (1000.0 * grams) / molarMass
    end
  end
end
