class Batch < ApplicationRecord
  has_many :isotherms
  has_many :mofs
end
