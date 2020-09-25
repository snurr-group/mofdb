class Gas < ApplicationRecord
  before_save :cleanup
  has_many :isodata
  has_many :isotherms, through: :isodata
  has_many :mofs, through: :isotherms

  def to_nist_json
    {id: self.id,
     InChIKey: self.inchikey,
     name: self.name,
     InChICode: self.inchicode,
     formula: self.formula,
    }

  end

  def cleanup
    self.name = name.split(" ").join("") unless name.nil?
    self.inchikey = inchikey.split(" ").join("") unless inchikey.nil?
    self.inchicode = inchicode.split(" ").join("") unless inchicode.nil?
    self.formula = formula.split(" ").join("") unless formula.nil?
  end

  def self.find_gas(name)
    gas = Gas.find_by(name: name)
    if gas.nil?
      gas = Gas.find_by(formula: name)
    end
    if gas.nil?
      syn = Synonym.find_by(name: name)
      gas = syn.gas unless syn.nil?
    end
    if gas.nil?
      gas = Gas.find_by(inchikey: name)
    end
    if gas.nil?
      gas = Gas.find_by(inchicode: name)
    end
    return gas

  end

end
