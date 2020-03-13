class MoreIndices < ActiveRecord::Migration[5.2]
  def up
    add_index :elements, :number
    add_index :elements, :name
    add_index :elements, :symbol
  end
  def down
    remove_index :elements, :number
    remove_index :elements, :name
    remove_index :elements, :symbol
  end
end
