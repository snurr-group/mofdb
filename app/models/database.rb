class Database < ApplicationRecord
  has_many :mofs
  validates :name, uniqueness: true

end
