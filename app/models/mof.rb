class Mof < ApplicationRecord
  belongs_to :database
  has_many :isotherms
  has_many :gases, through: :isotherms
  has_and_belongs_to_many :elements
end
