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

  def convert_adsorption_units_wrap(from, to, value, gas_molar_mass, mof, temp, pressure_bar)
    gas_from, gas_to, mof_from, mof_to = parseUnits(from.name, to.name)
    pressure_atm = pressure_bar / 1.01325
    numerator = convert_gas_unit(gas_from, gas_to, value, gas_molar_mass, temp, pressure_atm)
    denominator = convert_mof_unit(mof_from, mof_to, 1, mof.volumeA3, mof.atomicMass)
    numerator / denominator

  end

  def convert_adsorption_units(from, to, isodata)
    raise UnsupportedUnit.new("Unsupported unit #{from.name}") unless from.convertable
    raise UnsupportedUnit.new("Unsupported unit #{to.name}") unless to.convertable
    mof = isodata.isotherm.mof
    value = isodata.loading
    temp_k = isodata.isotherm.temp
    pressure_bar = get_pressure_in_bar(isodata)
    convert_adsorption_units_wrap(from, to, value, isodata.gas.molarMass, mof, temp_k, pressure_bar)
  end

  def convert_mof_unit(from, to, value, volumeA3, unit_cell_mass)

    from = "cm3(STP)" if from == "cm3"
    avogadro = 6.0221409e+23
    # volume of a mol of unit cells in cm3
    vol_mol_cm3 = (volumeA3 * avogadro) / 1e+24 #  [cm3/mol]

    if from == "cm3(STP)"
      mol_unit_cell = value / vol_mol_cm3
    elsif from == "g"
      mol_unit_cell = value / unit_cell_mass
    elsif from == "l"
      m3 = value / 1000.0
      cm3 = m3 * 100.0 * 100.0 * 100.0
      mol_unit_cell = cm3 / vol_mol_cm3
    elsif from == "kg"
      grams = value * 1000.0
      mol_unit_cell = grams / unit_cell_mass
    elsif from == "mg"
      grams = value / 1000.0
      mol_unit_cell = grams / unit_cell_mass
    else
      raise UnsupportedUnit.new("Can't convert mof unit '#{from}' as from unit'")
    end

    if to == "cm3"
      return mol_unit_cell * vol_mol_cm3
    elsif to == "g"
      return mol_unit_cell * unit_cell_mass
    elsif to == "l"
      cm3 = mol_unit_cell * vol_mol_cm3
      return cm3 / 1000.0
    elsif to == "kg"
      return (mol_unit_cell * unit_cell_mass) / 1000.0
    elsif to == "mg"
      return (mol_unit_cell * unit_cell_mass) * 1000.0
    else
      raise UnsupportedUnit.new("Can't convert mof unit '#{to}' as to unit")
    end

  end

  def convert_gas_unit(from, to, value, molar_mass, temp_k, pressure_atm)
    r = 0.082057
    temp_stp = 273.15
    atm_stp = 1

    from = "cm3(STP)" if from == "cm3"

    moles = nil

    moles = if from == "mg"
      g = value / 1000
      g / molar_mass
    elsif from == "mol"
      value
    elsif from == "g"
      value / molar_mass
    elsif from == "cm3"
      liters = value / 1000.0
      pressure_atm * liters / (r * temp_k)
    elsif from == "cm3(STP)"
      liters = value / 1000.0
      atm_stp * liters / (r * temp_stp)
    elsif from == "mmol"
      value / 1000.0
    else
      raise UnsupportedUnit.new("Unknown gas conversion from #{from}")
    end

    if to == "mg"
      return moles * molar_mass * 1000.0
    elsif to == "mol"
      return moles * molar_mass / molar_mass
    elsif to == "g"
      return moles * molar_mass
    elsif to == "cm3"
      return (moles * r * temp_k) / pressure_atm
    elsif to == "cm3(STP)"
      liters = moles * r * temp_stp / (atm_stp)
      return liters * 1000
    elsif to == "mmol"
      return 1000.0 * moles
    else
      raise UnsupportedUnit.new("We don't know how to convert from #{from} to --> #{to}, to is the problem")
    end
  end
end
