class MofsHaveBatch < ActiveRecord::Migration[6.0]
  def change
    add_column :mofs, :batch_id, :bigint
    add_index :mofs, :batch_id
    add_foreign_key :mofs, :batches
  end
end
