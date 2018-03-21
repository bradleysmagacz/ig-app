class AddAutoFollowOnToInstagramIdentities < ActiveRecord::Migration[5.0]
  def change
    change_table :instagram_identities do |t|
      t.boolean :auto_follow_on, default: false
    end
  end
end
