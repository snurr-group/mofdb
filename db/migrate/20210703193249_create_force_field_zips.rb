class CreateForceFieldZips < ActiveRecord::Migration[6.0]
  def change
    create_table :force_field_zips do |t|
      t.timestamps
      t.string :name, unique: true, null: false
    end
  end
end
