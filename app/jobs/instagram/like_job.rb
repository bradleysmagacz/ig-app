class Instagram::LikeJob < ApplicationJob
  include InstagramApiHelper

  def perform(args={})
    raise "instagram_identity_id required" unless args[:instagram_identity_id].present?
    raise "hashtag_id required." unless args[:hashtag_id].present?
    raise "media_id is required" unless args[:media_id].present?
    instagram_identity = InstagramIdentity.find(args[:instagram_identity_id])
    hashtag = instagram_identity.hashtags.find(args[:hashtag_id])
    if hashtag.auto_like_on
      media_id = args[:media_id]
      raise "instagram_identity #{instagram_identity.id} is rate limited" if instagram_identity.is_rate_limited?
      rate_limit = Instagram::RateLimit.likes.find_by(identifiable: instagram_identity)
      response = Api::Instagram.new(instagram_identity).like(media_id)
      if error_message = response["error_message"]
        raise error_message
      else
        Instagram::Like.create!(sender: instagram_identity.user, media_id: media_id)

        user = UserSerializer.new(instagram_identity.user)
        ActionCable.server.broadcast "dashobard_#{instagram_identity.user_id}", { user: user }
      end 
    else
      raise JobError.new(:none, "auto like already off for #{hashtag.name}")
    end
  end
end
