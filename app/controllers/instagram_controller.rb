class InstagramController < ApplicationController
  def create
    redirect_to "https://api.instagram.com/oauth/authorize?client_id=#{ENV['INSTAGRAM_CLIENT_ID']}&redirect_uri=#{ENV['INSTAGRAM_REDIRECT_URL']}&response_type=code&scope=basic+public_content+follower_list+comments+relationships+likes"
  end

  def callback
    if params[:error]
      render status: :forbidden, json: params
    elsif code = params[:code]
      response = HTTParty.post("https://api.instagram.com/oauth/access_token", body: {
        client_id: ENV['INSTAGRAM_CLIENT_ID'],
        client_secret: ENV['INSTAGRAM_SECRET'],
        grant_type: 'authorization_code',
        redirect_uri: ENV['INSTAGRAM_REDIRECT_URL'],
        code: code
      })
      json = JSON.parse(response.body || "{}")
      if json["error_message"]
        render status: response.code, body: response
      elsif token = json["access_token"]
        user_json = json["user"]
        user = current_user || User.where(username: user_json["username"]).first_or_create do |u|
          u.password = Devise.friendly_token
        end
        if user.errors.empty?
          identity = InstagramIdentity.where(api_id: user_json["id"]).first_or_initialize do |new_identity|
            new_identity.user = user
          end
          identity.website = user_json["website"]
          identity.username = user_json["username"]
          identity.bio = user_json["bio"]
          identity.full_name = user_json["full_name"]
          identity.token = token
          identity.save
          if identity.errors.empty?
            if url = user["profile_picture"]
              # Could fail so done as separate db transaction
              identity.profile_picture = URI.parse(url)          
              identity.save
            end

            json_user = UserSerializer.new(user)
            render status: :created, json: { user: json_user }
          else
            Error.unprocessable(identity.errors.full_messages)
          end
        else
          Error.unprocessable(user.errors.full_messages.first)
        end
      else
        Error.internal(self, "Instagram API Error (#{response.code}): #{body}")
      end
    else
      Error.internal self
    end
  end
end
