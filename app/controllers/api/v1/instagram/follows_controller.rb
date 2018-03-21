class Api::V1::Instagram::FollowsController < Api::V1::InstagramController
  include HashtagHelper

  def create 
    if hashtag = params[:hashtag]
      if is_valid_hashtag?(hashtag)
        ::Instagram::AutoFollowJob.perform_async(
          instagram_identity_id: current_user.instagram_identity.id,
          hashtag: hashtag
        )
        head :created
      else
        render status: :unprocessable_entity, json: { error: "Hashtag is invalid." }
      end
    else
      render status: :not_found, json: { error: "Hashtag is required." }
    end
  end
  
  def destroy
    hashtag = current_user.instagram_identity.hashtags.find(params[:hashtag_id])
    hashtag.update_attributes(auto_follow_on: false)
    user = UserSerializer.new(current_user)
    ActionCable.server.broadcast "dashboard_#{current_user.id}", { user: user }
    head :no_content
  end
end
