class CreateHashtags < ActiveRecord::Migration[5.0]
  def change
    remove_column :instagram_identities, :auto_follow_on, :boolean
    remove_column :instagram_identities, :auto_like_on, :boolean
    create_table :hashtags do |t|
      t.references :hashtaggable, polymorphic: true, index: true
      t.boolean :auto_follow_on, null: false, default: false
      t.boolean :auto_like_on, null: false, default: false
      t.boolean :auto_common_on, null: false, default: false
      t.string :name, null: false, index: true
    end
  end
end
