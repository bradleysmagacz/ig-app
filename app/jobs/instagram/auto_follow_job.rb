class Instagram::AutoFollowJob < ApplicationJob 
  include InstagramApiHelper

  def perform(args={})
    raise "instagram_identity_id is required" if args[:instagram_identity_id].nil?
    instagram_identity = InstagramIdentity.find(args[:instagram_identity_id])
    raise "hashtag required" if args[:hashtag].nil?
    hashtag = Hashtag.where(name: args[:hashtag], hashtaggable: instagram_identity).first_or_initialize
    raise "auto follow already turned on for hashtag #{hashtag.id}" if hashtag.auto_follow_on?
    hashtag.update_attributes!(auto_follow_on: true)
    api = Api::Instagram.new(instagram_identity)
    response = api.get_recent_media(hashtag)
    if response['error_message']
      raise "Instagram API error (#{instagram_identity.id}, #{hashtag.name}): #{response}"
    elsif users = extract_users(response['data'])
      rate_limit = Instagram::RateLimit.relationships.find_by(identifiable: instagram_identity)
      user_sample = users.take(rate_limit.current_limit)
      user_sample.each_with_index do |user, index|
        delay = rate_limit.randomized_delay(index).seconds
        Instagram::FollowJob.set(wait: delay).perform_async(
          instagram_identity_id: instagram_identity.id,
          user_id: user['id'],
          requeue: index == user_sample.count - 1,
          hashtag_id: hashtag.id
        )
      end
    else
      Rails.logger.info "Instagram::AutoFollowJob(#{instagram_identity.id}, #{hashtag.name}) ran but no users were found."
    end
    user = UserSerializer.new(instagram_identity.user)
    ActionCable.server.broadcast "dashboard_#{instagram_identity.user_id}", { user: user }
  end

  def extract_users(data={})
    users = []
    if data.is_a?(Hash)
      if users_in_photo = data['users_in_photo']
        users.merge(users_in_photo)
      end
      if user = data['user']
        users << user
      end
      if comments_data = data['comments']
        if comments_data['count'] > 0
          # TODO: fetch comments & extract
        end
      end
    elsif data.is_a?(Array)
      users = data
    end
    users
  end
end
