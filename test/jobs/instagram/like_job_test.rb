require 'test_helper'

class Instagram::LikeJobTest < ActiveJob::TestCase
  def instagram_identity
    instagram_identities :default
  end

  def global_rate_limit
    instagram_identity.rate_limits.global.first
  end

  def hashtag
    hashtags :active
  end

  def rate_limit
    instagram_identity.rate_limits.likes.first
  end

  def media_id
    '1'
  end

  def test_perform_requires_identity
    assert_raises RuntimeError do
      Instagram::LikeJob.new.perform
    end
  end

  def test_perform_requires_hashtag
    assert_raises RuntimeError do
      Instagram::LikeJob.new.perform(instagram_identity_id: instagram_identity.id)
    end
  end

  def test_perform_api_error
    error_message = 'haha'
    stub_instagram_request(:post, "/media/1/likes", instagram_identity).
      to_return(status: 400, body: { 'error_message': error_message }.to_json)
    assert_raises RuntimeError do
      Instagram::LikeJob.new.perform(instagram_identity_id: instagram_identity.id, media_id: media_id)
    end
  end

  def test_perform_rate_limited
    instagram_identity.rate_limits.likes.first.backoff!
    assert_raises RuntimeError do
      Instagram::LikeJob.new.perform(instagram_identity_id: instagram_identity.id, media_id: media_id)
    end
  end

  def test_perform
    stub_instagram_request(:post, "/media/1/likes", instagram_identity).
      to_return(status: 200, body: {}.to_json)
    Instagram::LikeJob.new.perform(
      instagram_identity_id: instagram_identity.id, hashtag_id: hashtag.id, media_id: media_id
    )
    assert_not_nil Instagram::Like.find_by(sender: instagram_identity.user, media_id: media_id)
    assert_equal 1, rate_limit.requests.count
    assert_equal 1, global_rate_limit.requests.count
  end
end
