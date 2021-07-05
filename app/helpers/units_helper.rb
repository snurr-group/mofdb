module UnitsHelper

  def supportedLoadingUnits
    # Units we can convert
    Classification.where(convertable: true, source: "loading")
    # %w[cm3(STP)/g cm3(STP)/cm3 g/l mg/g mmol/g mol/kg cm3/cm3]
  end

  def supportedPressureUnits
    Classification.where(convertable: true, source: "pressure")
    # %w[atm bar kPa mbar mmHg MPa Pa psi Torr]
  end


  def loadingUnits
    # Units we list on the frontend as loading conversion options
    %w[cm3(STP)/g cm3(STP)/cm3 g/l mg/g mmol/g mol/kg]
  end

  def pressureUnits
    # Units we list on the frontend as pressure conversion options
    %w[atm bar kPa mbar mmHg MPa Pa psi Torr]
  end

  class UnsupportedUnit < StandardError
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

  def get_pressure_in_bar(isodata)
    pressure_units = isodata.isotherm.pressure_units
    return isodata.pressure * pressure_units.data
  end


  def convert_pressure_units(isodata, to)
    bar = get_pressure_in_bar(isodata)
    return bar / to["data"]
  end

  def convert_adsorption_units_wrapped(from, to, value, gas, mof, temp, pressureBar)
    gasFrom, gasTo, mofFrom, mofTo = parseUnits(from.name, to.name)
    pressureAtm = pressureBar / 1.01325
    numerator = convert_gas_unit(gasFrom, gasTo, value, gas.molarMass, temp, pressureAtm)
    denominator = convert_mof_unit(mofFrom, mofTo, 1, mof.volumeA3, mof.atomicMass)
    return numerator / denominator

  end

  def convert_adsorption_units(from, to, isodata)
    raise UnsupportedUnit.new("Unsupported unit #{from.name}") if !from.convertable
    raise UnsupportedUnit.new("Unsupported unit #{to.name}") if !to.convertable
    gas = isodata.gas
    mof = isodata.isotherm.mof
    value = isodata.loading
    tempK = isodata.isotherm.temp
    pressureBar = get_pressure_in_bar(isodata)
    convert_adsorption_units_wrapped(from, to, value, gas, mof, tempK, pressureBar)
  end

  def convert_mof_unit(from, to, value, volumeA3, unitCellMass)

    from = "cm3(STP)" if from == "cm3"
    avogadro = 6.0221409e+23
    molesOfUnitCells = nil

    # volume of a mol of unit cells in cm3
    volumeMolCm3 = (volumeA3 * avogadro) / 1e+24 #  [cm3/mol]

    molarMass = unitCellMass

    if from == "cm3(STP)"
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
    else
      raise UnsupportedUnit.new("What? #{from}")
    end

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
    tempSTP = 273.15
    atmSTP = 1

    from = "cm3(STP)" if from == "cm3"

    moles = nil

    moles = if from == "mg"
      g = value / 1000
      g / molarMass
    elsif from == "mol"
      value
    elsif from == "g"
      value / molarMass
    elsif from == "cm3"
      liters = value / 1000.0
      pressureAtm * liters / (r * tempK)
    elsif from == "cm3(STP)"
      liters = value / 1000.0
      atmSTP * liters / (r * tempSTP)
    elsif from == "mmol"
      value / 1000.0
    else
      raise UnsupportedGasUnit("Unknown conversion from #{from}")
    end

    if to == "mg"
      return moles * molarMass * 1000.0
    elsif to == "mol"
      return moles * molarMass / molarMass
    elsif to == "g"
      return moles * molarMass
    elsif to == "cm3"
      return (moles * r * tempK) / pressureAtm
    elsif to == "cm3(STP)"
      liters = moles * r * tempSTP / (atmSTP)
      return liters * 1000
    elsif to == "mmol"
      return 1000.0 * moles
    else
      raise UnsupportedUnit("We don't know how to convert from #{from} to #{to}")
    end
  end
end
