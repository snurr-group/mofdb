class FixDoiTableName < ActiveRecord::Migration[6.0]
  def change
    rename_table :Doi, :dois
  end
end
