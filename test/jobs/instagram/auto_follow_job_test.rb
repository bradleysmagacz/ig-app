require 'test_helper'

class Instagram::AutoFollowJobTest < ActiveSupport::TestCase
  def instagram_identity
    instagram_identities :default
  end

  def hashtag
    'surfing'
  end

  def test_perform_requires_identity
    assert_raises RuntimeError do
      Instagram::AutoFollowJob.new.perform
    end
  end

  def test_perform_requires_hashtag
    assert_raises RuntimeError do
      Instagram::AutoFollowJob.new.perform(instagram_identity_id: instagram_identity.id)
    end
  end
  
  def test_perform_api_error
    stub_instagram_request(:get, "/tags/#{hashtag}/media/recent", instagram_identity).
      to_return(status: 401, body: { error_message: 'auth' }.to_json)
    assert_raises RuntimeError do
      Instagram::AutoFollowJob.new.perform(instagram_identity_id: instagram_identity.id, hashtag: hashtag)
    end
  end

  def test_perform_is_rate_limited
    instagram_identity.rate_limits.recent_media.first.backoff!
    assert_raises RuntimeError do
      Instagram::AutoFollowJob.new.perform(instagram_identity_id: instagram_identity.id, hashtag: hashtag)
    end
  end

  def test_perform
    rate_limit = instagram_identity.rate_limits.relationships.first
    stub_instagram_request(:get, "/tags/#{hashtag}/media/recent", instagram_identity).
      to_return(status: 200, body: { code: 200, data: instagram_users(rate_limit) }.to_json)
    instagram_users(rate_limit).each do |user|
      stub_instagram_request(:get, "/users/#{user['id']}/relationships", instagram_identity).
        to_return(status: 200)
    end
    Instagram::AutoFollowJob.new.perform({
      instagram_identity_id: instagram_identity.id,
      hashtag: 'surfing'
    })
    assert_equal instagram_users(rate_limit).count, Instagram::FollowJob.jobs.count
    assert Hashtag.find_by(name: hashtag, hashtaggable: instagram_identity).auto_follow_on?, "should have auto follow on"
    assert instagram_users(rate_limit).count, instagram_identity.rate_limits.global.first.requests.count
  end
end
