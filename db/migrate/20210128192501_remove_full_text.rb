class RemoveFullText < ActiveRecord::Migration[6.0]
  def change
    remove_index :mofs, [:mofid,:mofkey]
  end
end
