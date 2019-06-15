class CreateElements < ActiveRecord::Migration[5.2]
  def change
    create_table :elements do |t|
      t.integer :number
      t.string :name
      t.string :symbol

      t.timestamps
    end
  end
end
