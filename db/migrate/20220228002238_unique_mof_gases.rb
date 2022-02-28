class UniqueMofGases < ActiveRecord::Migration[6.1]
  def change
    add_index :gases_mofs, [:mof_id, :gas_id], unique: true
  end
end
