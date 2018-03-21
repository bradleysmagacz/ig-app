class Instagram::UnfollowJob < ApplicationJob
  include InstagramApiHelper

  def perform(args={})    
    raise "instagram_identity_id is required." if args[:instagram_identity_id].nil?
    raise "instagram_api_user_id is required." if args[:instagram_api_user_id].nil?
    instagram_identity = InstagramIdentity.find(args[:instagram_identity_id])
    api = Api::Instagram.new(instagram_identity)
    response = api.unfollow(args[:instagram_api_user_id])
    if response['error_message']
      raise "Instagram API error (#{instagram_identity.id}, #{args[:user_id]}): #{response}"
    else
      relationship = Relationship.where(user: instagram_identity.user, api_user_id: args[:instagram_api_user_id]).first_or_initialize 
      relationship.update_attributes!(outgoing_status: 'none')

      user = UserSerializer.new(instagram_identity.user)
      ActionCable.server.broadcast "dashboard_#{instagram_identity.user_id}", { user: user }
    end
  end
end
