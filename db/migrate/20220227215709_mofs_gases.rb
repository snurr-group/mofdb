class MofsGases < ActiveRecord::Migration[6.0]
  def up
    create_join_table :mofs, :gases, unique: true
    total = Mof.all.count
    num = 0
    Mof.all.in_batches(of: 100).each do |batch|
      num += 1
      puts "On #{num*100}/#{total}"
      batch.each do |mof|
        mof.save
      end
    end
  end

  def down
    drop_join_table :mofs, :gases
  end
end
