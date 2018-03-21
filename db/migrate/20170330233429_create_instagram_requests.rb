class CreateInstagramRequests < ActiveRecord::Migration[5.0]
  def change
    remove_column :rate_limits, :count, :integer
    create_table :requests do |t|
      t.datetime :expires_at, null: false
      t.belongs_to :rate_limit, null: false
    end
  end
end
