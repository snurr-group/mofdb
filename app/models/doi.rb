class Doi < ApplicationRecord
  has_many :isotherms
  validates :url, presence: true, uniqueness: true, length: {minimum: 1}
  validates :doi, presence: true, length: {minimum: 1}
end
