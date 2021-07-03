class ForceFieldZip < ApplicationRecord
  has_one_attached :file
  validates :name, uniqueness: true, presence: true
end
