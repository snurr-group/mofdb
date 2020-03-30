class IndexOnName < ActiveRecord::Migration[6.0]
  def up
    add_index :mofs, :name
  end
  def down
    remove_index :mofs, :name
  end
end
