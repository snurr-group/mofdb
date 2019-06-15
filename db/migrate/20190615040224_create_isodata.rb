class CreateIsodata < ActiveRecord::Migration[5.2]
  def change
    create_table :isodata do |t|
      t.references :isotherm, foreign_key: true
      t.references :gas, foreign_key: true
      t.float :pressure
      t.float :loading
      t.float :bulk_composition

      t.timestamps
    end
  end
end
