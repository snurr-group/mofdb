class CreateDatabases < ActiveRecord::Migration[5.2]
  def change
    create_table :databases do |t|
      t.string :name
    end
    add_foreign_key :mofs, :databases
  end
end
