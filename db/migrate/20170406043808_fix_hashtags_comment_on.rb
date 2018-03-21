class FixHashtagsCommentOn < ActiveRecord::Migration[5.0]
  def change
    remove_column :hashtags, :auto_common_on, :boolean
    add_column :hashtags, :auto_comment_on, :boolean, null: false, default: false
  end
end
