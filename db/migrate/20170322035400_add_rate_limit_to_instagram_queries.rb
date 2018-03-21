class AddRateLimitToInstagramQueries < ActiveRecord::Migration[5.0]
  def change
    create_table :rate_limits do |t|
      t.string :slug, null: false, index: true
      t.integer :hourly_limit, null: false
      t.integer :count, null: false, default: 0
      t.datetime :backoff_until
      t.integer :backoff_offset, null: false, default: 60
      t.belongs_to :identity
    end
  end
end
