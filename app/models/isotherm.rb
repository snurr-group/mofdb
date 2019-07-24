class Isotherm < ApplicationRecord
  belongs_to :adsorbate_forcefield, class_name: 'Forcefield'
  belongs_to :molecule_forcefield, class_name: 'Forcefield'
  belongs_to :mof
  has_many :isodata, dependent: :delete_all
  has_many :gases, through: :isodata

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


# Isotherm.new(adsorption_units_id: Classification.find(2),
#              forcefield: Forcefield.first,
#              mof: Mof.first,
#              pressure_units_id: Classification.find(10),
#              composition_type_id: Classification.first).save!