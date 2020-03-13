class CreateForcefields < ActiveRecord::Migration[5.2]
  def change
    create_table :forcefields do |t|
      t.string :name

      t.timestamps
    end
  end
end
