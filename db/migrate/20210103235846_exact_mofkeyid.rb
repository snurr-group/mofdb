class ExactMofkeyid < ActiveRecord::Migration[6.0]
  def change
    add_index :mofs, :mofid, name: "mofid_exact_match_idx", length: 768
    add_index :mofs, :mofkey, name: "mofkey_exact_match_idx", length: 768
  end
end
