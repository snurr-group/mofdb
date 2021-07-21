require 'open3'
require "#{Rails.root}/app/helpers/application_helper"
require "#{Rails.root}/app/helpers/units_helper"

class Mof < ApplicationRecord
  include UnitsHelper

  belongs_to :batch, optional: true
  belongs_to :database
  has_many :isotherms, dependent: :delete_all
  has_many :isodata, through: :isotherms
  has_many :gases, through: :isotherms
  has_many :adsorbate_forcefields, through: :isotherms
  has_many :molecule_forcefields, through: :isotherms
  has_many :adsorption_units, through: :isotherms
  has_many :pressure_units, through: :isotherms
  has_many :composition_type, through: :isotherms
  has_and_belongs_to_many :elements
  has_many :heats

  after_create :storeMassAndVol

  scope :visible, -> { where(:hidden => false) }
  scope :convertable, -> { where("volumeA3 is not NULL and atomicMass is not NULL") }

  def convertable
    !volumeA3.nil? && !atomicMass.nil?
  end

  def test
    isotherm_bad_units = false
    self.isotherms.map { |i| i.adsorption_units.name }.each do |name|
      unless supportedLoadingUnits.include?(name)
        isotherm_bad_units = true
      end
    end
    self.isotherms.map { |i| i.pressure_units.name }.each do |name|
      unless supportedPressureUnits.include?(name)
        isotherm_bad_units = true
      end
    end

    if isotherm_bad_units
      msg = "Cannot covert to your preferred units because one of this mofs isotherms includes a non-convertable unit"
    elsif !can_i_covert
      msg = "This mof is missing it's volume or molar mass and thus we cannot covert its units"
    else
      msg = nil
    end

    return (can_i_covert && !isotherm_bad_units), msg

  end

  def storeMassAndVol
    success = false
    write_cif_to_file
    begin
      cmd = "python3 #{Rails.root.join("lib", "massAndVol.py")} #{cif_path}"
      stdout_str, _, _ = Open3.capture3(cmd)
      result = JSON.load(stdout_str)
      self.volumeA3 = result['volumeA3']
      self.atomicMass = result['atomicMass']
      self.save!
      success = true
    rescue Exception => e
      puts e
      success = false
    ensure
      delete_cif
      return success
    end
  end

  def get_json(convertPressure, convertLoading)
    # Convenience method to render the view for caching
    ApplicationController.render(template: 'mofs/_mof.json.jbuilder',
                                 locals: { mof: self, convert_pressure: convertPressure,
                                           convert_loading: convertLoading },
                                 format: :json,
                                 assigns: { mof: self, convert_pressure: convertPressure,
                                            convert_loading: convertLoading })
  end

  def regen_json
    self.pregen_json = JSON.load(get_json(nil, nil))
    self.save
  end

  def cif_path
    id = 'id-' + self.id.to_s + '.cif'
    return Rails.root.join("tmp", id)
  end

  def write_cif_to_file

    tmp = File.open(cif_path, 'w+')
    tmp.write(self.cif)
    tmp.close()
  end

  def delete_cif
    File.delete(cif_path)
  end

end
