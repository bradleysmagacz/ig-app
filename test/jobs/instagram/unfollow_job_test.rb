require 'test_helper'

class UnfollowJobTest < ActiveJob::TestCase
  def instagram_identity
    instagram_identities :default
  end

  def global_rate_limit
    instagram_identity.rate_limits.global.first
  end

  def hashtag
    hashtag = hashtags :default
    hashtag.update_attributes!(auto_follow_on: true)
    hashtag
  end
  
  def rate_limit
    instagram_identity.rate_limits.relationships.first
  end

  def user_id
    '1'
  end

  def test_perform_instagram_identity_id_required
    assert_raises RuntimeError do
      Instagram::FollowJob.new.perform
    end
  end

  def test_perform_user_id_required
    assert_raises RuntimeError do
      Instagram::FollowJob.new.perform(instagram_identity_id: instagram_identity.id)
    end
  end

  def test_perform_api_error
    stub_instagram_request(:post, "/users/#{user_id}/relationship", instagram_identity).
      with(body: "access_token=#{instagram_identity.token}&action=unfollow").
      to_return(status: 400, body: { error_message: 'haha' }.to_json)
    assert_raises RuntimeError do 
      Instagram::UnfollowJob.new.perform(
        instagram_identity_id: instagram_identity.id,
        instagram_api_user_id: user_id
      )
      assert_nil Relationship.find_by(user: instagram_identity.user, api_user_id: user_id)
    end
  end

  def test_perform_rate_limited
    instagram_identity.rate_limits.relationships.first.backoff!
    assert_raises RuntimeError do
      Instagram::UnfollowJob.new.perform(
        instagram_identity_id: instagram_identity.id,
        instagram_api_user_id: user_id
      )
    end
  end

  def test_perform
    stub_instagram_request(:post, "/users/#{user_id}/relationship", instagram_identity).
      with(body: "access_token=#{instagram_identity.token}&action=unfollow").
      to_return(status: 200, body: { code: "200" }.to_json)
    Instagram::UnfollowJob.new.perform(
      instagram_identity_id: instagram_identity.id,
      instagram_api_user_id: user_id
    )
    relationship = Relationship.find_by(user: instagram_identity.user, api_user_id: user_id)
    assert_equal "none", relationship.outgoing_status, "should update relationship"
    assert_equal 1, rate_limit.requests.count
    assert_equal 1, global_rate_limit.requests.count
  end
end
