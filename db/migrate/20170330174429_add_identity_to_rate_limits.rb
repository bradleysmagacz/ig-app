class AddIdentityToRateLimits < ActiveRecord::Migration[5.0]
  def change
    remove_column :rate_limits, :identity_id, :integer
    change_table :rate_limits do |t|
      t.references :identifiable, polymorphic: true, index: true, null: false
    end
  end
end
