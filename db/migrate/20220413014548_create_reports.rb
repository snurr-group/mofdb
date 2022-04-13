class CreateReports < ActiveRecord::Migration[7.0]
  def change
    create_table :reports do |t|
      t.string :email
      t.string :description
      t.string :ip
      t.timestamps
    end
  end
end
