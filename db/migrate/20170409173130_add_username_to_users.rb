class AddUsernameToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :username, :string
    remove_column :users, :email, :string
    change_table :users do |t|
      t.string :email
    end
  end
end
