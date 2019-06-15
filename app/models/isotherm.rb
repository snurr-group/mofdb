class Isotherm < ApplicationRecord
  belongs_to :forcefield
  belongs_to :mof
  has_many :isodata
  has_many :gases, through: :isodata
end




# Isotherm.new(adsorption_units_id: Classification.find(2),
#              forcefield: Forcefield.first,
#              mof: Mof.first,
#              pressure_units_id: Classification.find(10),
#              composition_type_id: Classification.first).save!