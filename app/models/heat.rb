class Heat < ApplicationRecord
  belongs_to :mof
  belongs_to :classification
  belongs_to :gas

  validates :pressure, presence: true
  validates :value, presence: true

  validates :pressure_units, presence: true
  validates :value_units, presence: true
end