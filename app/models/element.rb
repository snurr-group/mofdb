class Element < ApplicationRecord
  has_and_belongs_to_many :mofs
  before_save :cleanup
  def cleanup
    self.name = name.split(" ").join("") unless name.nil?
    self.symbol = symbol.split(" ").join("") unless symbol.nil?
  end
end
