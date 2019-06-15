class CreateGases < ActiveRecord::Migration[5.2]
  def change
    create_table :gases do |t|
      t.string :inchikey
      t.string :name
      t.text :inchicode
      t.text :formula
    end
  end
end
