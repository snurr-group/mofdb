class Classification < ApplicationRecord
  before_save :cleanup

  enum source: [ :pressure, :loading, :other ]

  def cleanup
    self.name = name.split(" ").join("") unless name.nil?
  end

end
