class MofElementJoin < ActiveRecord::Migration[5.2]
  def change
    create_join_table :mofs, :elements, unique: true
  end
end
