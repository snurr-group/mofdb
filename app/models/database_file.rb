class DatabaseFile < ApplicationRecord
  has_one_attached :file
  validates :name, uniqueness: true, presence: true
  validates :category, presence: true
end
