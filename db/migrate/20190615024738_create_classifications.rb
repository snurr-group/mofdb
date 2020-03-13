class CreateClassifications < ActiveRecord::Migration[5.2]
  def change
    create_table :classifications do |t|
      t.string :name
      t.float :data
      t.integer :source

      t.timestamps
    end
  end
end
