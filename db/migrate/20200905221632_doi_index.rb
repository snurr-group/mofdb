class DoiIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :isotherms, :doi
  end
end
