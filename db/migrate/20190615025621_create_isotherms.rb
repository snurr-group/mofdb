class CreateIsotherms < ActiveRecord::Migration[5.2]
  def change
    create_table :isotherms do |t|
      t.string :doi
      t.string :digitizer
      t.float :temp
      t.text :simin

      t.bigint :adsorbate_forcefield_id, foreign_key: true
      t.bigint :molecule_forcefield_id, foreign_key: true
      t.references :mof, foreign_key: true

      t.references :adsorption_units
      t.references :pressure_units
      t.references :composition_type
      t.timestamps
    end
    add_foreign_key :isotherms, :forcefields, column: 'adsorbate_forcefield_id'
    add_foreign_key :isotherms, :forcefields, column: 'molecule_forcefield_id'
    add_foreign_key :isotherms, :classifications, column: "adsorption_units_id"
    add_foreign_key :isotherms, :classifications, column: "pressure_units_id"
    add_foreign_key :isotherms, :classifications, column: "composition_type_id"


  end
end
