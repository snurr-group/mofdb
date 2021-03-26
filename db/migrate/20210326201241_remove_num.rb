class RemoveNum < ActiveRecord::Migration[6.0]
  def change
    remove_column :batches, :number, :bigint
  end
end
