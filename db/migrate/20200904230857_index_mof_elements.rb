class IndexMofElements < ActiveRecord::Migration[6.0]
  def change
    add_index :elements_mofs, :mof_id
    add_index :elements_mofs, :element_id
  end
end
