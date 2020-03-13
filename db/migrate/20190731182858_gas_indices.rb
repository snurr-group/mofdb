class GasIndices < ActiveRecord::Migration[5.2]
  def up
    change_column :gases, :inchicode, :string, limit: 500
    change_column :gases, :formula, :string, limit: 500
    add_index :gases, :name
    add_index :gases, :inchicode
    add_index :gases, :inchikey
    add_index :gases, :formula
  end

  def down
    remove_index :gases, :formula
    remove_index :gases, :name
    remove_index :gases, :inchicode
    remove_index :gases, :inchikey
    change_column :gases, :formula, :text
    change_column :gases, :inchicode, :text
  end
end
