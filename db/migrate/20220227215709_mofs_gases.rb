class MofsGases < ActiveRecord::Migration[6.0]
  def up
    create_join_table :mofs, :gases, unique: true
    Mof.all.in_batches(of: 100).each do |batch|
      puts "batch..."
      batch.each do |mof|
        mof.save
      end
    end
  end

  def down
    drop_join_table :mofs, :gases
  end
end
