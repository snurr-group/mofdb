class IndexMofsOnTextural < ActiveRecord::Migration[6.0]
  def change
    add_index :mofs, :pld
    add_index :mofs, :lcd
    add_index :mofs, :void_fraction
    add_index :mofs, :surface_area_m2g
    add_index :mofs, :surface_area_m2cm3
  end
end
