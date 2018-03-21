require 'test_helper'

class InstagramControllerTest < ActionController::TestCase
  def user
    users :default
  end

  def code
    "12345"
  end

  def client_id
    ENV['INSTAGRAM_CLIENT_ID']
  end

  def redirect_uri
    ENV['INSTAGRAM_REDIRECT_URL']
  end

  def response_type
    "code"
  end
  
  def scope
    "basic+public_content+follower_list+comments+relationships+likes"
  end

  def test_create_new_user
    get :create
    assert_redirected_to "https://api.instagram.com/oauth/authorize?client_id=#{client_id}&redirect_uri=#{redirect_uri}&response_type=#{response_type}&scope=#{scope}"
  end

  def test_create_existing_user
    sign_in user
    get :create
    assert_redirected_to "https://api.instagram.com/oauth/authorize?client_id=#{client_id}&redirect_uri=#{redirect_uri}&response_type=#{response_type}&scope=#{scope}"
  end

  def test_callback_api_error
    sign_in user
    error_message = "sup"
    post :callback, params: { error: { message: error_message } }, format: :json
    assert_equal 403, response.code.to_i
    assert_equal error_message, json['error']['message']
  end

  def test_callback_secondary_api_error
    sign_in user
    error_message = "okay okay"
    stub_request(:post, "https://api.instagram.com/oauth/access_token").with(body: URI.encode_www_form({
      client_id: ENV['INSTAGRAM_CLIENT_ID'],
      client_secret: ENV['INSTAGRAM_SECRET'],
      grant_type: "authorization_code",
      redirect_uri: ENV['INSTAGRAM_REDIRECT_URL'],
      code: code
    })).to_return(status: 422, body: { error_message: error_message }.to_json)
    post :callback, params: { code: code }, format: :json
    assert_equal 422, response.code.to_i
    assert_equal error_message, json['error_message']
  end

  def test_callback_new_user
    access_token = "token"
    user = { id: "haha", website: "something", username: "might", bio: "be", full_name: "missing" }
    stub_request(:post, "https://api.instagram.com/oauth/access_token").with(body: URI.encode_www_form({
      client_id: ENV['INSTAGRAM_CLIENT_ID'],
      client_secret: ENV['INSTAGRAM_SECRET'],
      grant_type: "authorization_code",
      redirect_uri: ENV['INSTAGRAM_REDIRECT_URL'],
      code: code
    })).to_return(status: 200, body: { access_token: access_token, user: user }.to_json)
    post :callback, params: { code: code }, format: :json
    assert_equal 201, response.code.to_i
    assert_equal [:id, :email, :username, :authentication_token, :full_name, :hashtags,
      :instagram_connected, :stats].map(&:to_s).sort, json["user"].keys.sort 
    identity = InstagramIdentity.find_by(token: access_token)
    assert_not_nil identity.user
    assert_equal user.merge(access_token: access_token).values.sort, identity.serializable_hash.values.reject { |value|
      !value.is_a?(String)
    }.sort
  end

  def test_callback_user_signed_in
    sign_in user
    access_token = "token"
    user = { id: "haha", website: "something", username: "might", bio: "be", full_name: "missing" }
    stub_request(:post, "https://api.instagram.com/oauth/access_token").with(body: URI.encode_www_form({
      client_id: ENV['INSTAGRAM_CLIENT_ID'],
      client_secret: ENV['INSTAGRAM_SECRET'],
      grant_type: "authorization_code",
      redirect_uri: ENV['INSTAGRAM_REDIRECT_URL'],
      code: code
    })).to_return(status: 200, body: { access_token: access_token, user: user }.to_json)
    post :callback, params: { code: code }, format: :json
    assert_equal 201, response.code.to_i
    identity = InstagramIdentity.find_by(token: access_token)
    assert_not_nil identity.user
    assert_equal user.merge(access_token: access_token).values.sort, identity.serializable_hash.values.reject { |value|
      !value.is_a?(String)
    }.sort
  end

  def test_callback_existing_user
    access_token = "token"
    user = { id: "haha", website: "something", username: users(:default).username, bio: "be", full_name: "missing" }
    stub_request(:post, "https://api.instagram.com/oauth/access_token").with(body: URI.encode_www_form({
      client_id: ENV['INSTAGRAM_CLIENT_ID'],
      client_secret: ENV['INSTAGRAM_SECRET'],
      grant_type: "authorization_code",
      redirect_uri: ENV['INSTAGRAM_REDIRECT_URL'],
      code: code
    })).to_return(status: 200, body: { access_token: access_token, user: user }.to_json)
    post :callback, params: { code: code }, format: :json
    assert_equal 201, response.code.to_i
    assert_equal 1, User.where(username: user[:username]).count
  end
end
