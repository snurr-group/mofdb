class AtomicMassAndVolume < ActiveRecord::Migration[6.0]
  def change
    add_column :mofs, :atomicMass, :float
    add_column :mofs, :volumeA3, :float
  end
end
