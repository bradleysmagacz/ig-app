class HashtagSerializer < ActiveModel::Serializer
  attributes :id, :name, :auto_follow_on, :auto_like_on, :auto_comment_on
end
