class IsothermBatchNum < ActiveRecord::Migration[6.0]
  def change
    create_table :batches do |t|
      t.integer :number, unique: true, index: true
    end
    add_column :isotherms, :batch_id, :bigint
    add_index :isotherms, :batch_id
    add_foreign_key :isotherms, :batches
  end
end
