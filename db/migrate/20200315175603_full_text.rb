class FullText < ActiveRecord::Migration[6.0]
  def up
    remove_index :mofs, :mofid
    remove_index :mofs, :mofkey
    add_index :mofs, :mofid, type: :fulltext
    add_index :mofs, :mofkey, type: :fulltext
  end
  def down
    remove_index :mofs, [:mofid,:mofkey]
  end
end
