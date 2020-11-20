require 'open3'

class Mof < ApplicationRecord
  belongs_to :database
  has_many :isotherms, dependent: :delete_all
  has_many :isodata, through: :isotherms
  has_many :gases, through: :isotherms
  has_and_belongs_to_many :elements
  has_many :heats

  after_create :storeMassAndVol

  scope :visible, -> { where(:hidden => false) }

  def storeMassAndVol
    success = false
    write_cif_to_file
    begin
      cmd = "python3 #{Rails.root.join("lib","massAndVol.py")} #{cif_path}"
      stdout_str, stderr_str, status = Open3.capture3(cmd)
      result = JSON.load(stdout_str)
      self.volumeA3 = result['volumeA3']
      self.atomicMass = result['atomicMass']
      self.save!
      # puts result
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
