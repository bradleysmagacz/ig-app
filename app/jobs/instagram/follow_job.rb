class Instagram::FollowJob < ApplicationJob
  include InstagramApiHelper

  def perform(args={})
    raise "instagram_identity_id is required" if args[:instagram_identity_id].nil?
    instagram_identity = InstagramIdentity.find(args[:instagram_identity_id])
    raise "user_id is required" if args[:user_id].nil?
    raise "hashtag_id is required." if args[:hashtag_id].nil?
    hashtag = Hashtag.find(args[:hashtag_id])
    raise "hashtag #{hashtag.id} has auto_follow turned off" if !hashtag.auto_follow_on?
    api = Api::Instagram.new(instagram_identity)
    response = api.follow(args[:user_id])
    if response['error_message']
      raise "Instagram API error: #{response}"
    elsif data = response['data']
      instagram_user_id = data['id']
      relationship = Relationship.where(
        user: instagram_identity.user,
        api_user_id: args[:user_id]
      ).first_or_initialize
      relationship.outgoing_status = data['outgoing_status']
      relationship.incoming_status = data['incoming_status']
      relationship.save!

      user = UserSerializer.new(instagram_identity.user)
      ActionCable.server.broadcast "dashboard_#{instagram_identity.user_id}", { user: user }

      # Queue unfollow job
      delay = Time.zone.now + 1.week
      Instagram::UnfollowJob.perform_in(delay, {
        instagram_identity_id: instagram_identity.id,
        user_id: args[:user_id]
      })
    
      # Queue next auto follow batch if specified   
      if args[:requeue] 
        Instagram::AutoFollowJob.perform_async(
          instagram_identity_id: instagram_identity.id,
          hashtag: hashtag.name
        )
      end
    end
  end
end
