class RemoveFullText < ActiveRecord::Migration[6.0]
  def change
    remove_index mofs, name: "index_mofs_on_mofid"
    remove_index mofs, name: "index_mofs_on_mofkey"
  end
end
