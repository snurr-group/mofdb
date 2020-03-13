class Heats < ActiveRecord::Migration[5.2]
  def up
    create_table :heats do |t|
      t.float :pressure
      t.float :value
      t.references :gas
      t.references :value_units
      t.references :pressure_units
      t.references :mof

    end
    add_foreign_key :heats, :classifications, column: "pressure_units_id"
    add_foreign_key :heats, :classifications, column: "value_units_id"

  end
  def down
    drop_table :heats
  end
end
