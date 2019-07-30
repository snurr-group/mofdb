class RemoveAndAddIndices < ActiveRecord::Migration[5.2]
  def up
    add_index :mofs, :hashkey
    add_index :classifications, :name
  end

  def down
    remove_index :mofs, :hashkey
    remove_index :classifications, :name

    add_index :isotherms, :temp
  end
end
