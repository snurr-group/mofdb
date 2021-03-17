require 'open3'
require "#{Rails.root}/app/helpers/application_helper"
require "#{Rails.root}/app/helpers/units_helper"

class Mof < ApplicationRecord
  include UnitsHelper

  belongs_to :database
  has_many :isotherms, dependent: :delete_all
  has_many :isodata, through: :isotherms
  has_many :gases, through: :isotherms
  has_and_belongs_to_many :elements
  has_many :heats

  after_create :storeMassAndVol

  scope :visible, -> { where(:hidden => false) }

  def can_covert
    can_covert = !self.volumeA3.nil? && !self.atomicMass.nil?


    isotherm_bad_units = false

    self.isotherms.map { |i| Classification.find(i.adsorption_units_id).name }.each do |name|
      isotherm_bad_units = true unless supportedLoadingUnits.include?(name)
    end
    self.isotherms.map { |i| Classification.find(i.pressure_units_id).name }.each do |name|
      isotherm_bad_units = true unless supportedPressureUnits.include?(name)
    end

    msg = if isotherm_bad_units
            "Cannot covert to your preferred units because one of this mofs isotherms includes a non-convertable unit"
          elsif !can_covert
            "This mof is missing it's volume or molar mass and thus we cannot covert its units"
          else
            nil
          end

    return (can_covert && !isotherm_bad_units),  msg

  end

  def storeMassAndVol
    success = false
    write_cif_to_file
    begin
      cmd = "python3 #{Rails.root.join("lib","massAndVol.py")} #{cif_path}"
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

  def regen_json
    json = ApplicationController.render(template: 'mofs/_mof.json.jbuilder',
                                        locals: {mof: self},
                                        format: :json,
                                        assigns: {mof: self})
    json = JSON.load(json)
    self.pregen_json = json
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
