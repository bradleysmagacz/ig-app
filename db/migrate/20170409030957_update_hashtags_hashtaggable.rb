class UpdateHashtagsHashtaggable < ActiveRecord::Migration[5.0]
  def change
    remove_column :hashtags, :hashtaggable_type, :string
    remove_column :hashtags, :hashtaggable_id, :integer
    change_table :hashtags do |t|
      t.references :hashtaggable, polymorphic: true, null: false
    end
  end
end
