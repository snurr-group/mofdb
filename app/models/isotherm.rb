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
  has_many :isodata, dependent: :delete_all
  has_many :gases, through: :isodata
  belongs_to :batch, optional: true
  after_save :regen_mof_json

  def regen_mof_json
    self.mof.regen_json
  end

  def is_duplicate
    # Check if this isotherm is a duplciate of any others, if so return true
    is_dupe = false
    my_points  = self.isodatum_set # Set of points in this isotherm
    Isotherm.where(mof: self.mof, temp: self.temp).where.not(id: self.id).each do |iso|
      is_dupe = true if iso.isodatum_set == my_points
    end
    return is_dupe
  end

  def isodatum_set
    isodatum = Set.new
    self.isodata.each do |datum|
      isodatum.add({'pressure': datum.pressure,
                    'loading': datum.loading,
                    'bulk_composition': datum.bulk_composition, })
    end
    return isodatum
  end

end