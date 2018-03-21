class InstagramCookieService
  def initialize(instagram_identity)
    @instagram_identity = instagram_identity
  end

  def instagram_cookies_string
    json = default_cookie_json # TODO: implement instagram_identity
    json['i.instagram.com']['/'].reduce('') do |cookie_string, (cookie_name, cookie_json)|
      cookie_string + "; #{cookie_name}=#{cookie_json['value']}" 
    end
  end

  private

  attr_reader :instagram_identity
  attr_writer :json

  def default_cookie_json
    file = File.read(Rails.root.join("data/instagram_cookie.json"))
    JSON.parse file # TODO: symbolize_names
  end
end
