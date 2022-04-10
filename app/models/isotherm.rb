require "#{Rails.root}/app/helpers/application_helper"
require "#{Rails.root}/app/helpers/units_helper"

class Isotherm < ApplicationRecord
  include UnitsHelper

  belongs_to :adsorbate_forcefield, class_name: 'Forcefield'
  belongs_to :molecule_forcefield, class_name: 'Forcefield'
  belongs_to :adsorption_units, class_name: "Classification", :foreign_key => "adsorption_units_id"
  belongs_to :pressure_units, class_name: "Classification", :foreign_key => "pressure_units_id"
  belongs_to :composition_type, class_name: "Classification", :foreign_key => "composition_type_id"
  belongs_to :mof
  belongs_to :batch, optional: true
  has_many :isodata, dependent: :delete_all
  has_many :gases, through: :isodata
  after_save :regen_mof_json
  belongs_to :doi

  # Isotherms table contains kinds of isotherms
  # 1. Regular isotherms (not_heats)
  # 2. Heats of adsorption (any isotherm with adsorption_units.source == 'heat')
  #    See Classification.rb enum source
  # Scopes are used to separate them in ui/json responses

  # Does this isotherm have adsorption_units and pressure_units that are marked convertable?
  scope :convertable, -> { joins("JOIN classifications as clas_adsorp on isotherms.adsorption_units_id = clas_adsorp.id")
                             .joins("JOIN classifications as clas_pressure on isotherms.pressure_units_id = clas_pressure.id")
                             .where("clas_pressure.convertable  = true and clas_adsorp.convertable = true") }

  scope :heats, -> { joins("JOIN classifications as clas_heat on isotherms.adsorption_units_id = clas_heat.id")
                       .where("clas_heat.source = ?", Classification.sources[:heat])}

  scope :not_heats, -> { joins("JOIN classifications as clas_no_heat on isotherms.adsorption_units_id = clas_no_heat.id")
                           .where("clas_no_heat.source != ?", Classification.sources[:heat])}

  def is_convertable
    self.adsorption_units.convertable && self.pressure_units.convertable
  end

  def is_heat
    self.adsorption_units.source == "heat"
  end

  def regen_mof_json
    puts "regen mof json"
    self.mof.regen_json unless Rails.env.test?
  end

  def is_duplicate
    # Check if this isotherm is a dupe of any others, if so return true
    is_dupe = false
    my_points = self.isodatum_set # Set of points in this isotherm
    Isotherm.where(mof: self.mof, temp: self.temp).where.not(id: self.id).each do |iso|
      is_dupe = true if iso.isodatum_set == my_points
    end
    is_dupe
  end

  def isodatum_set
    isodata = Set.new
    self.isodata.each do |datum|
      isodata.add({ 'pressure': datum.pressure,
                    'loading': datum.loading,
                    'bulk_composition': datum.bulk_composition, })
    end
    isodata
  end

  def points(
    can_convert_pressure, # Do we have enough information to convert pressure units
    can_convert_loading, # ^
    convert_pressure, # A Classification object to convert pressure/loading to
    convert_loading # ^
  )

    points = {}
    self.isodata.each do |isodata|
      pressure = can_convert_pressure ?
                   convert_pressure_units(isodata, convert_pressure) :
                   isodata.pressure
      loading = can_convert_loading ?
                  convert_adsorption_units(self.adsorption_units, convert_loading, isodata) :
                  isodata.loading
      subpoint = { 'inchikey': isodata.gas.inchikey,
                   'gas_name': isodata.gas.name,
                   'composition': isodata.bulk_composition,
                   'adsorption': loading }
      unless points.key?(pressure)
        points[pressure] = {}
        points[pressure]['total_adsorption'] = 0.0
      end
      points[pressure]['total_adsorption'] += loading
      if points[pressure]['entries']
        points[pressure]['entries'] << subpoint
      else
        points[pressure]['entries'] = [subpoint]
      end
    end
    points
  end
end