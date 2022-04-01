class RemoveOldDoi < ActiveRecord::Migration[6.0]
  def change
    remove_column :isotherms, :doi
    change_column :isotherms, :doi_id, :bigint,  null: false
  end
end
