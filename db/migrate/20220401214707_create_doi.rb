class CreateDoi < ActiveRecord::Migration[6.0]
  def up
      create_table :Doi do |t|
        t.string :doi, null: false, unique: true, minlength: 1
        t.string :url, null: false, minlength: 1
        t.timestamps
      end

    add_column :isotherms, :doi_id, :bigint
    add_index :isotherms, :doi_id
    add_foreign_key :isotherms, :doi
  end
end
