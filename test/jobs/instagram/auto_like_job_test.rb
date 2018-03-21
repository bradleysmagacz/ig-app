require 'test_helper'

class Instagram::AutoLikeJobTest < ActiveJob::TestCase
  include InstagramApiHelper

  def instagram_identity
    instagram_identities :default
  end

  def user
    instagram_identity.user
  end
  
  def rate_limit
    instagram_identity.rate_limits.likes.first
  end

  def hashtag
    hashtags :default
  end

  def test_perform_requires_instagram_identity_id
    assert_raises ActiveRecord::RecordNotFound do
      Instagram::AutoLikeJob.new.perform
    end
  end

  def test_perform_requires_hashtag
    assert_raises ActiveRecord::RecordNotFound do
      Instagram::AutoLikeJob.new.perform(instagram_identity_id: instagram_identity.id)
    end
  end
  
  def test_perform_api_error
    stub_instagram_request(:get, "/tags/#{hashtag.name}/media/recent", instagram_identity).
      to_return(status: 401, body: { error_message: 'auth' }.to_json)
    assert_raises JobError do
      Instagram::AutoLikeJob.new.perform(instagram_identity_id: instagram_identity.id,
                                         hashtag_id: hashtag.id)
    end
  end

  def test_perform_is_rate_limited
    instagram_identity.rate_limits.likes.first.backoff!
    assert_raises JobError do
      Instagram::AutoLikeJob.new.perform(instagram_identity_id: instagram_identity.id,
                                         hashtag_id: hashtag.id)
    end
  end

  def test_perform
    stub_instagram_request(:get, "/tags/#{hashtag.name}/media/recent", instagram_identity).
      to_return(status: 200, body: { code: 200, data: instagram_medias(rate_limit) }.to_json)
    instagram_medias(rate_limit).each do |media_id|
      stub_instagram_request(:post, "/media/#{media_id}/likes", instagram_identity).
        to_return(status: 200)
    end
    Instagram::AutoLikeJob.new.perform({
      instagram_identity_id: instagram_identity.id,
      hashtag_id: hashtag.id
    })
    assert_equal instagram_medias(rate_limit).count, Instagram::LikeJob.jobs.count
    assert_equal 1, Instagram::AutoLikeJob.jobs.count
  end
end
