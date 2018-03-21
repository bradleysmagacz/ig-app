class DashboardChannel < ApplicationCable::Channel
  def subscribed
    stream_from "dashboard_#{current_user.id}"
    update_user
    Instagram::StatsJob.perform_async(instagram_identity_id: current_user.instagram_identity.id)
  end

  def unsubscribed
  end

  private

  def update_user
    user = UserSerializer.new(current_user)
    ActionCable.server.broadcast "dashboard_#{current_user.id}", { user: user }
  end
end
