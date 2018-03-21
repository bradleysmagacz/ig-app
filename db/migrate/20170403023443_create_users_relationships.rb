class CreateUsersRelationships < ActiveRecord::Migration[5.0]
  def change
    create_table :relationships do |t|
      t.belongs_to :user, null: false
      t.string :api_user_id, null: false
      t.string :outgoing_status
      t.string :incoming_status
    end
  end
end
