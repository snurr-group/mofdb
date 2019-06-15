class Isodatum < ApplicationRecord
  belongs_to :isotherm
  belongs_to :gas
end