class Classification < ApplicationRecord

  before_save :cleanup

  def cleanup
    self.name = name.split(" ").join("") unless name.nil?
  end

end
