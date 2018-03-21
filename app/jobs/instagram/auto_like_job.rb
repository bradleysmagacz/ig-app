class Instagram::AutoLikeJob < ApplicationJob
  include InstagramApiHelper

  def perform(args={})
    instagram_identity = InstagramIdentity.find(args[:instagram_identity_id])
    hashtag = instagram_identity.hashtags.find(args[:hashtag_id])
    api = Api::Instagram.new(instagram_identity)
    response = api.get_recent_media(hashtag)
    if response['error_message']
      raise JobError.new(:error, "Instagram API error (#{instagram_identity.id}, #{hashtag.name}): #{response}")
    elsif medias = response['data']
      rate_limit = Instagram::RateLimit.likes.find_by(identifiable: instagram_identity)
      medias.take(rate_limit.current_limit).each_with_index do |media, index|
        delay = rate_limit.randomized_delay(index).seconds
        Instagram::LikeJob.perform_in(
          delay, instagram_identity.id, hashtag.id, media['id']
        )
      end
      Instagram::AutoLikeJob.perform_in(1.hour.seconds, args)
    else
      raise JobError.new(:none, "Instagram::AutoLikeJob(#{instagram_identity.id}, #{hashtag.name}) ran but no media was found.")
    end
    user = UserSerializer.new(instagram_identity.user)
    ActionCable.server.broadcast "dashboard_#{instagram_identity.user_id}", { user: user }
  end
end
