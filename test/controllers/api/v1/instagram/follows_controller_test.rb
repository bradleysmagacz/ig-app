require 'test_helper'

class Api::V1::Instagram::FollowsControllerTest < ActionController::TestCase
  def hashtag
    hashtags :default
  end

  def instagram_identity
    instagram_identities :default
  end

  def invalid_hashtags
    ['', 'a', 'bad hashtag', '*&^%$#@"!~`+=)(/?>.<,', '🙌']
  end

  def user
    instagram_identity.user
  end

  def test_create_401
    post :create, format: :json
    assert_equal 401, response.code.to_i
  end

  def test_create_require_hashtag
    set_basic_auth(user)
    post :create, format: :json
    assert_equal 404, response.code.to_i
  end

  def test_create_invalid_hashtag
    set_basic_auth(user)
    invalid_hashtags.each do |hashtag|
      post :create, params: { hashtag: hashtag }, format: :json
      assert_equal 422, response.code.to_i, "#{hashtag} should be unprocessable"
      assert_not_nil json["error"], "#{hashtag} should have error message"
    end
  end

  def test_create_not_insta_connected
    no_insta_user = users :no_instagram
    set_basic_auth(no_insta_user)
    post :create, params: { hashtag: hashtag.name }, format: :json
    assert_equal 401, response.code.to_i
    assert_not_nil json["error"], "should respond with error message"
  end

  def test_create
    set_basic_auth(user)
    hashtag = 'surfing'
    Instagram::AutoFollowJob.stub :perform_async, [instagram_identity.id, hashtag] do
      post :create, params: { hashtag: hashtag }, format: :json
      assert_equal 201, response.code.to_i
    end
  end

  def test_destroy_401
    delete :destroy, format: :json
    assert_equal 401, response.code.to_i
  end

  def test_destroy_404
    set_basic_auth user
    other_hashtag = hashtags :other
    delete :destroy, params: { hashtag_id: other_hashtag.id }, format: :json
    assert_equal 404, response.code.to_i
  end

  def test_destroy_not_insta_connected
    no_insta_user = users :no_instagram
    set_basic_auth(no_insta_user)
    delete :destroy, params: { hashtag_id: hashtag.id }, format: :json
    assert_equal 401, response.code.to_i
    assert_not_nil json["error"], "should respond with error message"
  end

  def test_destroy
    set_basic_auth user
    hashtag.update_attributes!(auto_follow_on: true)
    delete :destroy, params: { hashtag_id: hashtag.id }, format: :json
    assert_equal 204, response.code.to_i
    assert_nil Hashtag.find_by(name: hashtag.name)
  end

  def test_destroy_auto_like_on
    set_basic_auth user
    hashtag.update_attributes!(auto_like_on: true)
    delete :destroy, params: { hashtag_id: hashtag.id }, format: :json
    assert_equal 204, response.code.to_i
    assert_not_nil Hashtag.find(hashtag.id)
  end
end
