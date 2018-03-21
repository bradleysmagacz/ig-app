class Api::V1::BaseController < ApplicationController
  before_action :authenticate!

  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def render_unprocessable_entity(exception)
    render json: exception.record.errors, status: :unprocessable_entity
  end

  def render_not_found(exception=nil)
    render json: { error: exception&.message || 'Not found.' }, status: :not_found
  end

  def render_bad_request(message='')
    render status: :bad_request, json: { error: message }
  end

  protected

  def instagram_api_service
    identity = current_user&.instagram_identity
    @instagram_api_service ||= Api::Instagram.new(identity)
  end

  private

  def authenticate!
    email = request.headers['X-User-Email'].presence || params[:email].presence
    username = request.headers['X-User-Username'].presence || params[:username].presence
    token = request.headers['X-User-Token'].presence || params[:token].presence 
    user = (email && User.find_by(email: email)) || (username && User.find_by(username: username))
    if token && user && Devise.secure_compare(user.authentication_token, token)
      sign_in user, store: false
    else
      head :unauthorized
    end
  end
end
