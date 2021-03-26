class BatchTimestamp < ActiveRecord::Migration[6.0]
  def change
    add_column :batches, :created_at, :datetime, null: false
    add_column :batches, :updated_at, :datetime, null: false
    change_column_null :batches, :number, false
  end
end
