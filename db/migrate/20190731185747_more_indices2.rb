class MoreIndices2 < ActiveRecord::Migration[5.2]
  def up
    add_index :databases, :name
    add_index :classifications, :source
    remove_index :classifications, :name
    add_index :classifications, :name, unique: true
  end
  def down
    remove_index :databases, :name
    remove_index :classifications, :source
    remove_index :classifications, :name
    add_index :classifications, :name
  end
end
