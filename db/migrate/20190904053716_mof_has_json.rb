class MofHasJson < ActiveRecord::Migration[5.2]
  def change
    add_column :mofs, :pregen_json, :json
  end
end
