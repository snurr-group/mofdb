class Gas < ApplicationRecord
  before_save :cleanup

  def cleanup
    self.name = name.split(" ").join("") unless name.nil?
    self.inchikey = inchikey.split(" ").join("") unless inchikey .nil?
    self.inchicode = inchicode.split(" ").join("") unless inchicode .nil?
    self.formula = formula.split(" ").join("") unless formula .nil?
  end

end