class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :username, :full_name, :authentication_token, :stats,
    :hashtags, :instagram_connected

  def stats
    instagram_identity&.stats_breakdown || empty_stats
  end

  def hashtags
    ActiveModelSerializers::SerializableResource.new(
      instagram_identity&.hashtags || [],
      each_serializer: HashtagSerializer
    )
  end

  def instagram_identity
    object.instagram_identity
  end

  private

  def empty_stats
    Stat.keys.map { |key|
      [key, { year: 0, month: 0, week: 0, today: 0 }]
    }.to_h
  end
end
