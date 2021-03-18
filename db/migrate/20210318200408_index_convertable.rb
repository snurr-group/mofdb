class IndexConvertable < ActiveRecord::Migration[6.0]
  def change
    add_index :classifications, :convertable
    add_index :mofs, :volumeA3
    add_index :mofs, :atomicMass
  end
end
