class Isodatum < ApplicationRecord
  belongs_to :isotherm
  belongs_to :gas
  has_one :mof, through: :isotherm

  validates :bulk_composition, presence: true
  validates :loading, presence: true
  validates :pressure, presence: true


end