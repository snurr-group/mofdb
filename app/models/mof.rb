class Mof < ApplicationRecord
  belongs_to :database
  has_many :isotherms, dependent: :delete_all
  has_many :gases, through: :isotherms
  has_and_belongs_to_many :elements
  has_many :heats


end
