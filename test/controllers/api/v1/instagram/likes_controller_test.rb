require 'test_helper'

class Api::V1::Instagram::LikesControllerTest < ActionController::TestCase
  def instagram_identity
    instagram_identities :default
  end

  def user
    instagram_identity.user
  end

  def hashtag
    hashtags :default
  end
  
  def test_create_401
    post :create, format: :json
    assert_equal 401, response.code.to_i
  end

  def test_create_require_hashtag
    set_basic_auth(user)
    post :create, format: :json
    assert_equal 400, response.code.to_i
  end

  def test_create_not_insta_connected
    no_insta_user = users :no_instagram
    set_basic_auth(no_insta_user)
    post :create, params: { hashtag: hashtag.name }, format: :json
    assert_equal 401, response.code.to_i
    assert_not_nil json["error"], "should respond with error message"
  end

  def test_create_already_exists
    set_basic_auth(user)
    post :create, params: { hashtag: hashtag.name }, format: :json
    assert_equal 200, response.code.to_i
  end

  def test_create
    set_basic_auth(user)
    hashtag_name = 'somethingelse'
    mock = MiniTest::Mock.new
    mock.expect :perform, [instagram_identity.id, hashtag_name]
    Instagram::AutoLikeJob.stub :new, mock do
      post :create, params: { hashtag: hashtag_name }, format: :json
      assert_equal 201, response.code.to_i
      assert_equal true, Hashtag.find_by(name: hashtag_name).auto_like_on?
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
    assert_equal 200, response.code.to_i
    assert_not_nil json, "should respond with user"
    assert_equal Hashtag.find(hashtag.id).auto_like_on?, false
  end
end
