class Api::V1::Instagram::LikesController < Api::V1::InstagramController
  before_action :find_hashtag, only: [:create]

  def create
    if @hashtag.present?
      head :ok
    else
      @hashtag = current_user.instagram_identity.hashtags.create(
        name: params.permit(:hashtag)[:hashtag],
        auto_like_on: true
      )
      if @hashtag.errors.empty?
        ::Instagram::AutoLikeJob.perform_async(
          instagram_identity_id: current_user.instagram_identity.id,
          hashtag_id: @hashtag.id
        )
        render status: :created, json: current_user.reload
      else
        render_bad_request(@hashtag.errors.full_messages)
      end
    end
  rescue JobError => error
    render_bad_request(error)
  end

  def destroy
    hashtag = current_user.hashtags.find(params[:hashtag_id])
    hashtag.update_attributes(auto_like_on: false)
    ActionCable.server.broadcast "dashboard_#{current_user.id}", { user: current_user }
    render json: current_user
  end

  private

  def find_hashtag
    hashtag = params.permit(:hashtag)[:hashtag]
    if hashtag.present?
      @hashtag = current_user.hashtags.find_by(name: hashtag)
    else
      render_bad_request('Hashtag required.') and return 
    end
  end
end
