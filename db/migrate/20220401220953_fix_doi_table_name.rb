class FixDoiTableName < ActiveRecord::Migration[6.0]
  def change
    rename_table :doi, :dois
  end
end
