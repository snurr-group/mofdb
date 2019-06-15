class CreateGas < ActiveRecord::Migration[5.2]
  def change
    create_table :gas do |t|
      t.string :inchikey
      t.string :name
      t.text :inchicode
      t.text :formula

      t.timestamps
    end
  end
end
