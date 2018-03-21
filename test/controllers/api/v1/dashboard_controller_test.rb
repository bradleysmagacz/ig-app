require 'test_helper'

class Api::V1::DashboardControllerTest < ActionController::TestCase
  def json
    JSON.parse response.body, symbolize_names: true
  end

  def instagram_identity
    instagram_identities :default
  end

  def user
    instagram_identity.user
  end

  def test_index_401
    get :index, format: :json
    assert_equal 401, response.code.to_i
  end

  def test_index_not_oauth_instagram
    no_insta_user = users :default
    set_basic_auth(no_insta_user)
    get :index, format: :json
    Stat.keys.each do |key|
      stat = json[:stats][key]
      assert_not_nil stat, "should have empty stats"
      assert_equal [:today, :week, :month, :year].sort, stat.keys.map(&:to_sym).sort
    end
  end

  def test_index
    set_basic_auth(user)
    get :index, format: :json
    assert_equal [:id, :full_name, :email, :authentication_token, :stats, :hashtags,
                  :instagram_connected, :username].sort, json.keys.sort
    assert_equal Stat.keys.sort, json[:stats].keys.map(&:to_sym).sort
    assert_equal [
      :id, :auto_follow_on, :auto_like_on, :auto_comment_on, :name
    ].sort, json[:hashtags].first.keys.map(&:to_sym).sort
  end
end
