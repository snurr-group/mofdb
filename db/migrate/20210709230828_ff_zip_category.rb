class FfZipCategory < ActiveRecord::Migration[6.0]
  def change
    rename_table :force_field_zips, :database_files
    add_column :database_files, :category, :string
    add_index :database_files, :category
  end
end
