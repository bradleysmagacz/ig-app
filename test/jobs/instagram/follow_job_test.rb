require 'test_helper'

class FollowJobTest < ActiveSupport::TestCase
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

  def test_perform_hashtag_id_required
    assert_raises RuntimeError do
      Instagram::FollowJob.new.perform(
        instagram_identity_id: instagram_identity.id,
        user_id: user_id
      )
    end
  end

  def test_perform_api_error
    user_id = 1
    stub_instagram_request(:post, "/users/#{user_id}/relationship", instagram_identity).
      with(body: "access_token=#{instagram_identity.token}&action=follow").
      to_return(status: 400, body: { error_message: 'haha' }.to_json)
    assert_raises RuntimeError do 
      Instagram::FollowJob.new.perform(
        instagram_identity_id: instagram_identity.id,
        user_id: user_id,
        hashtag_id: hashtag.id
      )
      assert_nil Relationship.find_by(user: instagram_identity.user, api_user_id: user_id)
    end
  end

  def test_perform_rate_limited
    instagram_identity.rate_limits.relationships.first.backoff!
    assert_raises RuntimeError do
      Instagram::FollowJob.new.perform(
        instagram_identity_id: instagram_identity.id,
        user_id: user_id,
        hashtag_id: hashtag.id
      )
    end
  end

  def test_perform
    stub_instagram_request(:post, "/users/#{user_id}/relationship", instagram_identity).
      with(body: "access_token=#{instagram_identity.token}&action=follow").
      to_return(status: 200, body: { code: "200", data: { outgoing_status: "requested" }}.to_json)
    Instagram::FollowJob.new.perform(
      instagram_identity_id: instagram_identity.id,
      user_id: user_id,
      hashtag_id: hashtag.id
    )
    assert_equal 1, Instagram::UnfollowJob.jobs.count
    relationship = Relationship.find_by(user: instagram_identity.user, api_user_id: user_id)
    assert_equal "requested", relationship.outgoing_status, "should create relationship"
    assert_equal 1, rate_limit.requests.count
    assert_equal 1, global_rate_limit.requests.count
  end

  def test_perform_requeue
    stub_instagram_request(:post, "/users/#{user_id}/relationship", instagram_identity).
      with(body: "access_token=#{instagram_identity.token}&action=follow").
      to_return(status: 200, body: { code: "200", data: { outgoing_status: "requested" }}.to_json)
    Instagram::FollowJob.new.perform(
      instagram_identity_id: instagram_identity.id,
      user_id: user_id,
      hashtag_id: hashtag.id,
      requeue: true
    )
    assert_equal 1, Instagram::UnfollowJob.jobs.count
    assert_equal 1, Instagram::AutoFollowJob.jobs.count
    relationship = Relationship.find_by(user: instagram_identity.user, api_user_id: user_id)
    assert_equal "requested", relationship.outgoing_status, "should create relationship"
    assert_equal 1, rate_limit.requests.count
    assert_equal 1, global_rate_limit.requests.count
  end
end
