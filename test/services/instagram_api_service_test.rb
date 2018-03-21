require 'test_helper'

class InstagramApiServiceTest < ActionController::TestCase
  def instagram_api_id
    '12345'
  end

  def instagram_identity
    instagram_identities :default
  end

  def user
    instagram_identity.user
  end

  def test_follow
    stub_instagram_request(:get, "/users/#{instagram_api_id}/relationships", instagram_identity).
      to_return(status: 200)
  end
end
