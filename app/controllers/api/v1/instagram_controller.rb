class Api::V1::InstagramController < Api::V1::BaseController
  before_action :ensure_instagram_connected

  protected

  def ensure_instagram_connected
    unless current_user.instagram_connected
      render status: :unauthorized, json: {
        error: "You need to authenticate instagram before using this feature."
      }
    end
  end
end
