module Instagram
  class RateLimit < ActiveRecord::Base
    belongs_to :identifiable, polymorphic: true

    has_many :requests

    scope :global, -> { where(slug: "global") }
    scope :recent_media, -> { where(slug: "/tags/tag-name/media/recent") }
    scope :comments, -> { where(slug: "/media/media-id/comments") }
    scope :likes, -> { where(slug: "/media/media-id/likes") }
    scope :relationships, -> { where(slug: "/users/user-id/relationships") }

    def self.all_slugs
      ["global", "/tags/tag-name/media/recent", "/media/media-id/comments",
        "/media/media-id/likes", "/users/user-id/relationships"]
    end

    def backoff!
      date = backoff_until || DateTime.now
      update_attributes!(backoff_until: date + backoff_offset.minutes, backoff_offset: backoff_offset * 2)
    end

    def current_limit
      hourly_limit - requests.count
    end
    
    def randomized_delay(index=0)
      rand(request_delay * (index + 1))
    end

    def is_rate_limited?
      requests.count >= hourly_limit || backoff_until
    end

    def increment_request_count!
      expires_at = DateTime.now + 1.hour
      Request.create!(expires_at: expires_at, rate_limit: self)
      if backoff_until
        update_attributes!(backoff_until: nil, backoff_offset: 60)
      end
      if slug != "global"
        # Increment global request counter
        identifiable.rate_limits.global.first.increment_request_count!
      end
    end

    def request_delay # in seconds
      Float(3600) / current_limit
    end
  end
end
