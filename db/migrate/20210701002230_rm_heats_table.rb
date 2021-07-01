class RmHeatsTable < ActiveRecord::Migration[6.0]
  def change
    drop_table "heats"
  end
end
