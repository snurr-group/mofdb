class CreateMofs < ActiveRecord::Migration[5.2]
  def change
    create_table :mofs do |t|
      t.string :hashkey
      t.string :name
      t.bigint :database_id
      t.text :cif
      t.float :void_fraction
      t.float :surface_area_m2g
      t.float :surface_area_m2cm3
      t.float :pld
      t.float :lcd
      t.text :pxrd
      t.text :pore_size_distribution

      t.timestamps
    end
  end
end
