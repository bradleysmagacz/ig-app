require 'test_helper'

class Instagram::StatsJobTest < ActiveJob::TestCase
  def instagram_identity
    instagram_identities :default
  end
  
  def instagram_user
    { 
      "counts": {
        "media": stats_today.num_media,
        "follows": stats_today.num_follows,
        "followed_by": stats_today.num_followed_by
      }
    }
  end

  def stats_last_year
    stats :last_year
  end

  def stats_last_month
    stats :last_month
  end

  def stats_last_week
    stats :last_week
  end

  def stats_yesterday
    stats :yesterday
  end

  def stats_today
    stats :today
  end

  def user
    instagram_identity.user
  end

  def test_perform_requires_instagram_identity_id
    assert_raises RuntimeError do
      Instagram::StatsJob.new.perform
    end
  end

  def test_perform_api_failure
    stub_instagram_request(:get, "/users/self", instagram_identity).
      to_return(status: 429, body: { error_message: 'haha' }.to_json)
    assert_raises RuntimeError do
      Instagram::StatsJob.new.perform(instagram_identity_id: instagram_identity.id)
    end
  end

  def test_perform_rate_limited
    instagram_identity.rate_limits.global.first.backoff!
    assert_raises RuntimeError do
      Instagram::StatsJob.new.perform(instagram_identity_id: instagram_identity.id)
    end
  end

  def test_perform
    stub_instagram_request(:get, "/users/self", instagram_identity).
      to_return(status: 200, body: { data: instagram_user }.to_json)
    Instagram::StatsJob.new.perform(instagram_identity_id: instagram_identity.id)
    stats = instagram_identity.stats_breakdown
    [:num_media, :num_follows, :num_followed_by
     # TODO: , :num_likes_received, :num_likes_sent, :num_comments_received, :num_comments_sent
     ].each do |attr|
      assert_equal stats_today[attr] - stats_last_year[attr], stats[attr][:year], "#{attr} should accurately count last year"
      assert_equal stats_today[attr] - stats_last_month[attr], stats[attr][:month], "#{attr} should accurately count last month"
      assert_equal stats_today[attr] - stats_last_week[attr], stats[attr][:week], "#{attr} should accurately count last week"
      assert_equal stats_today[attr] - stats_yesterday[attr], stats[attr][:today], "#{attr} should accurately count yesterday"
    end
  end
end
