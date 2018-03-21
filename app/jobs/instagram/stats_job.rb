class Instagram::StatsJob < ApplicationJob
  include InstagramApiHelper

  def perform(args={})
    raise "instagram_identity_id is required." unless args[:instagram_identity_id].presence
    instagram_identity = InstagramIdentity.find(args[:instagram_identity_id])
    api = Api::Instagram.new(instagram_identity)
    response = api.get_self
    if message = response['error_message']
      raise "Instagram API Error: #{message}"
    elsif user = response['data']
      Stat.create!(
        stattable: instagram_identity,
        num_media: user['counts']['media'],
        num_follows: user['counts']['follows'],
        num_followed_by: user['counts']['followed_by']
      )

      user = UserSerializer.new(instagram_identity.user)
      ActionCable.server.broadcast "dashboard_#{instagram_identity.user_id}", { user: user }
    end
  end
end
