class AddAutoLikeOnToInstagramIdentities < ActiveRecord::Migration[5.0]
  def change
    change_table :instagram_identities do |t|
      t.boolean :auto_like_on, null: false, default: false
    end
  end
end
