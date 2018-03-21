require 'test_helper'

class Api::V1::SessionsControllerTest < ActionController::TestCase
  def user
    users :default
  end

  def invalid_email
    'random@'
  end

  def valid_email
    'test@example.com'
  end

  def test_create_401
    post :create, format: :json
    assert_equal 401, response.code.to_i
  end

  def test_create_invalid_email
    post :create, params: { user: { email: invalid_email, password: 'abc123' }}, format: :json
    assert_equal 401, response.code.to_i
  end

  def test_create
    User.create!(email: valid_email, password: 'abc123')
    post :create, params: { user: { email: valid_email, password: 'abc123' } }, format: :json
    assert_equal 201, response.code.to_i
    assert_equal json['user']['email'], valid_email
    assert_equal [:id, :email, :full_name, :authentication_token, :stats, :hashtags,
      :instagram_connected, :username].sort, json['user'].keys.map(&:to_sym).sort
  end

  def test_destroy_401
    delete :destroy, format: :json
    assert_equal 204, response.code.to_i
  end

  def test_destroy
    sign_in user
    delete :destroy, format: :json
    assert_equal 204, response.code.to_i
  end
end
