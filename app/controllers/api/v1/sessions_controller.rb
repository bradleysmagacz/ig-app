class Api::V1::SessionsController < Devise::SessionsController
  include ApplicationHelper

  respond_to :json

  def create
    if params[:user].nil?
      head :unauthorized
      return
    end
    email = params[:user][:email].presence
    user = email && User.find_by(email: email)
    password = params[:user][:password].presence
    if user.nil?
      render status: :unauthorized, json: { error: "No user exists with that email." }
    elsif password.nil? || !user.valid_password?(password)
      render status: :unauthorized, json: { error: "Password is invalid." }
    else 
      sign_in user
      render status: :created, json: { user: UserSerializer.new(user) }
    end
  end
end
