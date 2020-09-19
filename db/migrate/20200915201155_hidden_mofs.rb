class HiddenMofs < ActiveRecord::Migration[6.0]
  def up
    add_column :mofs, :hidden, :boolean, default: false, null: false
    add_index :mofs, :hidden
  end
  def down
    remove_column :mofs, :hidden
  end
end
