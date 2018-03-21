class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
    end
    create_table :instagram_identities do |t|
      t.belongs_to :user, null: false
      t.string :website
      t.string :api_id, index: true
      t.string :full_name
      t.string :token, index: true
      t.text :bio
      t.string :username, index: true
    end
    add_attachment :instagram_identities, :profile_picture
  end
end
