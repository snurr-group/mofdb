class ClassificationConvertable < ActiveRecord::Migration[6.0]
  def change
    add_column :classifications, :convertable, :boolean, default: :false
  end
end
