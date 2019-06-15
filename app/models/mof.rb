class Mof < ApplicationRecord
  belongs_to :database
  has_many :isotherms
  has_many :gases, through: :isotherms
end
