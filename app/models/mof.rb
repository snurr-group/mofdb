class Mof < ApplicationRecord
  belongs_to :database
  has_many :isotherms, dependent: :delete_all
  has_many :isodata, through: :isotherms
  has_many :gases, through: :isotherms
  has_and_belongs_to_many :elements
  has_many :heats

  def regen_json
    json = ApplicationController.render(template: 'mofs/_mof.json.jbuilder',
                                        locals: {mof: self},
                                        format: :json,
                                        assigns: {mof: self})
    json = JSON.load(json)
    self.pregen_json = json
    self.save
  end


  def write_cif_to_file
    id = 'id-' + self.id.to_s + '.cif'
    tmp = File.open(Rails.root.join("/","tmp", id), 'w+')
    tmp.write(self.cif)
    tmp.close()
  end

  def delete_cif
    id = "id-" + self.id.to_s + ".cif"
    File.delete(Rails.root.join("/","tmp", id))
  end

end
