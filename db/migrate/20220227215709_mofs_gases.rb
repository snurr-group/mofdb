class MofsGases < ActiveRecord::Migration[6.0]
  def up
    create_join_table :mofs, :gases, unique: true
    Mof.all.each do |mof|
      mof.save
    end
  end
  def down
    drop_join_table :mofs, :gases
  end
end
