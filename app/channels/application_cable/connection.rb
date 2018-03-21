module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags current_user.id
    end

    private

    def find_verified_user
      email = request.params[:email].presence
      token = request.params[:token].presence
      user = email && User.find_by(email: email)
      if token && user && Devise.secure_compare(user.authentication_token, token)
        user
      else
        reject_unauthorized_connection
      end
    end
  end
end
