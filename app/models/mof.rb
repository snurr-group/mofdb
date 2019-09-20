class Mof < ApplicationRecord
  belongs_to :database
  has_many :isotherms, dependent: :delete_all
  has_many :isodata, through: :isotherms
  has_many :gases, through: :isotherms
  has_and_belongs_to_many :elements
  has_many :heats

  def regen_json
    json = ApplicationController.render(template: 'mofs/_mof.json.jbuilder', locals: {mof: mof}, format: :json, assigns: { mof: mof })
    json = JSON.load(json)
    self.pregen_json = json
    self.save
  end
end
