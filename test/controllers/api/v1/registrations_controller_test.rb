require 'test_helper'

class Api::V1::RegistrationsControllerTest < ActionController::TestCase
  def invalid_email
    'invalid@'
  end

  def valid_email
    'test@example.com'
  end

  def user
    users :default
  end

  def test_create_invalid_email
    post :create, params: { email: invalid_email, password: 'abc123' }, format: :json
    assert_equal 422, response.code.to_i
  end

  def test_create
    user_data = { email: valid_email, password: 'abc123', password_confirmation: 'abc123' }
    post :create, params: { user: user_data }, format: :json
    assert_equal 201, response.code.to_i
    assert_not_nil User.find_by(email: valid_email)
    assert_equal [
      :id, :email, :full_name, :authentication_token, :stats, :hashtags, :instagram_connected, :username
    ].sort, json.keys.map(&:to_sym).sort
  end

  def test_update_401
    put :update, format: :json
    assert_equal 401, response.code.to_i
  end

  def test_update
    sign_in user
    new_name = 'newnew'
    put :update, params: { user: { full_name: new_name, current_password: 'abc123' }}, format: :json
    assert_equal 204, response.code.to_i
    assert_equal new_name, user.reload.full_name, "should update user data"
  end

  def test_destroy_401
    delete :destroy, format: :json
    assert_equal 401, response.code.to_i
  end

  def test_destroy
    sign_in user
    delete :destroy, format: :json
    assert_equal 204, response.code.to_i
    assert_nil User.find_by(email: user.email)
  end
end
