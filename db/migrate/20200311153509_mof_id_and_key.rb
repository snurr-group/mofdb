class MofIdAndKey < ActiveRecord::Migration[6.0]

  def up
    add_column :mofs, :mofid, :text
    add_column :mofs, :mofkey, :text
    add_index :mofs, :mofid, length: 1000
    add_index :mofs, :mofkey, length: 1000
  end

  def down
    remove_index :mofs, :mofid
    remove_index :mofs, :mofkey
    remove_column :mofs, :mofid
    remove_column :mofs, :mofkey
  end

end
