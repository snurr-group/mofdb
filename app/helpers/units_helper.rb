module UnitsHelper

  def supportedUnits
    return ["cm3/cm3", "cm3(STP)/g", "cm3(STP)/cm3", "g/l", "mg/g", "mmol/g", "mol/kg"]
  end

  class UnsupportedGasUnit < StandardError
    def initialize(msg = nil)
      super
    end
  end

  def parseUnits(from, to)
    def parseUnit(unit)
      split = unit.split("/")
      return split[0], split[1]
    end

    gasFrom, mofFrom = parseUnit(from)
    gasTo, mofTo = parseUnit(to)
    return gasFrom, gasTo, mofFrom, mofTo
  end


  def convert_adsorption_units(from, to, isodata)
    raise UnsupportedGasUnit.new("#{from} is not a supported adsorption unit") unless supportedUnits.include?(from)
    raise UnsupportedGasUnit.new("#{to} is not a supported adsorption unit") unless supportedUnits.include?(to)
    gas = isodata.gas
    mof = isodata.isotherm.mof
    value = isodata.loading
    tempK = isodata.isotherm.temp
    pressureBar = isodata.pressure

    gasFrom, gasTo, mofFrom, mofTo = parseUnits(from, to)

    pressureAtm = pressureBar / 1.01325
    numerator = convert_gas_unit(gasFrom, gasTo, value, gas.molarMass, tempK, pressureAtm)
    denominator = convert_mof_unit(mofFrom, mofTo, 1, mof.volumeA3, mof.atomicMass)
    return numerator / denominator


  end

  def convert_mof_unit(from, to, value, volumeA3, unitCellMass)
    supported = ["cm3", "g", "l", "kg", "mg"]
    raise UnsupportedGasUnit("#{from} is not a supported MOF unit") if supported.index(from).nil?
    raise UnsupportedGasUnit("#{to} is not a supported MOF unit") if supported.index(to).nil?

    avogadro = 6.0221409e+23
    molesOfUnitCells = nil

    # volume of a mol of unit cells
    volumeMolCm3 = (volumeA3 * avogadro) / 1e+24 #  [cm3/mol]
    #     # puts "volumeMolCm3: #{volumeMolCm3}, volumeA3: #{volumeA3}, unitCellMass: #{unitCellMass}"

    # molar mass of mof
    molarMass = unitCellMass # [g/mol]

    if from == "cm3"
      molesOfUnitCells = value / volumeMolCm3
    elsif from == "g"
      molesOfUnitCells = value / molarMass
    elsif from == "l"
      m3 = value / 1000.0
      cm3 = m3 * 100.0 * 100.0 * 100.0
      molesOfUnitCells = cm3 / volumeMolCm3
    elsif from == "kg"
      grams = value * 1000.0
      molesOfUnitCells = grams / molarMass
    elsif from == "mg"
      grams = value / 1000.0
      molesOfUnitCells = grams / molarMass
    end

    # puts "moles of unit cells is #{molesOfUnitCells}"


    if to == "cm3"
      return molesOfUnitCells * volumeMolCm3
    elsif to == "g"
      return molesOfUnitCells * molarMass
    elsif to == "l"
      cm3 = molesOfUnitCells * volumeMolCm3
      return cm3 / 1000.0
    elsif to == "kg"
      return (molesOfUnitCells * molarMass) / 1000.0
    elsif to == "mg"
      return (molesOfUnitCells * molarMass) * 1000.0
    end
  end

  def convert_gas_unit(from, to, value, molarMass, tempK, pressureAtm)
    r = 0.082057
    atmSTP = 1
    tempSTP = 273.15

    supported = ["cm3", "cm3(STP)", "g", "mg", "mmol", "mol"]
    raise UnsupportedGasUnit.new("#{from} is not a supported gas unit") if supported.index(from).nil?
    raise UnsupportedGasUnit.new("#{to} is not a supported gas unit") if supported.index(to).nil?

    moles = nil

    # Convert everything into grams
    if from == "mg"
      g = value / 1000
      moles = g / molarMass
    elsif from == "mol"
      moles = value
    elsif from == "g"
      moles = value / molarMass
    elsif from == "cm3"
      liters = value / 1000.0
      moles = pressureAtm * liters / (r * tempK)
    elsif from == "cm3(STP)"
      liters = value / 1000.0
      moles = atmSTP * liters / (r * tempSTP)
    elsif from == "mmol"
      moles = value / 1000.0
    end

    # puts "moles of gas: #{moles}"

    if to == "mg"
      return moles * molarMass * 1000.0
    elsif to == "mol"
      return moles * molarMass / molarMass
    elsif to == "g"
      return moles * molarMass
    elsif to == "cm3"
      return (moles * r * tempK * 1000.0) / pressureAtm
    elsif to == "cm3(STP)"
      liters = moles * r * tempSTP / (atmSTP)
      return liters * 1000
    elsif to == "mmol"
      return 1000.0 * moles
    end
  end
end
