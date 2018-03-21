class CreateStats < ActiveRecord::Migration[5.0]
  def change
    create_table :stats do |t|
      t.references :stattable, polymorphic: true
      t.bigint :num_likes_received, null: false, default: 0, limit: 13
      t.bigint :num_likes_sent, null: false, default: 0, limit: 13
      t.bigint :num_follows, null: false, default: 0, limit: 13
      t.bigint :num_followed_by, null: false, default: 0, limit: 13
      t.bigint :num_comments_received, null: false, default: 0, limit: 13
      t.bigint :num_comments_sent, null: false, default: 0, limit: 13
      t.bigint :num_media, null: false, default: 0, limit: 13
      t.timestamps
    end
  end
end
