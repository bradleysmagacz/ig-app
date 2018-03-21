module InstagramApiService
  module Api
    class Instagram
      include HTTParty
      base_uri 'https://api.instagram.com/v1'

      def initialize(instagram_identity)
        @instagram_identity = instagram_identity
      end

      def follow(api_user_id)
        update_user_relationship('follow', api_user_id)
      end

      def get_recent_media(hashtag)
        return JSON.parse(error: "hashtag is required.") if hashtag.nil?
        return is_rate_limited if is_rate_limited
        rate_limit = ::Instagram::RateLimit.recent_media.find_by(identifiable: @instagram_identity)
        response = self.class.get("/tags/#{hashtag}/media/recent",
                                  query: { access_token: @instagram_identity.token })
        rate_limit.increment_request_count!
        process(rate_limit, response)
      end

      def get_relationship(instagram_user_id)
        return is_rate_limited if is_rate_limited
        rate_limit = @instagram_identiy.rate_limits.relationships.first
        return nil if query_limit.is_rate_limited?
        response = process(rate_limit, self.class.get("/users/#{instagram_user_id}/relationship",
                                  query: { access_token: @instagram_identity.token }))
        rate_limit.increment_request_count!
        relationship = Relationship.where(sender: @instagram_identity.user, receiver_id: instagram_user_id).first_or_create!
        if data = response[:data]
          relationship.update_attributes!(outgoing_status: data[:outgoing_status], incoming_status: data[:incoming_status])
        end
        relationship
      end

      def get_self
        return is_rate_limited if is_rate_limited
        rate_limit = @instagram_identity.rate_limits.global.first
        response = self.class.get("/users/self", query: { access_token: @instagram_identity.token })
        rate_limit.increment_request_count!
        process(rate_limit, response)
      end

      def get_users(hashtag)
        return is_rate_limited if is_rate_limited
        response = get_recent_media(hashtag)
        if data = response[:data]
          data.map do |media|
            media[:user]
          end
        end
      end

      def is_rate_limited
        { error_message: "Instagram has rate limited you." }.to_json if @instagram_identity.is_rate_limited?
      end

      def like(media_id)
        return is_rate_limited if is_rate_limited
        rate_limit = @instagram_identity.rate_limits.likes.first
        response = self.class.post("/media/#{media_id}/likes", body: {
          access_token: @instagram_identity.token 
        })
        rate_limit.increment_request_count!
        process(rate_limit, response)
      end

      def unfollow(api_user_id)
        update_user_relationship('unfollow', api_user_id)
      end

      private

      def process(rate_limit, response)
        case response.code
        when 429
          ActionCable.server.broadcast "dashboard_#{@instagram_identity.user_id}", error: {
            code: 429,
            message: "Rate limit exceeded. Sleeping for #{rate_limit.backoff_offset / 60} hours"
          }
          Rails.logger.fatal "Instagram Identity #{@instagram_identity.id}: rate limit exceeded. Sleeping for #{rate_limit.backoff_offset / 60} hours"
          rate_limit.backoff!
        when 200
          Rails.logger.info "Completed Instagram API request"
        else
          Rails.logger.warn "Unexpected Instagram API response (#{response.code}): #{response.body}"
        end
        JSON.parse(response.body || "{}")
      end

      def update_user_relationship(action_name, api_user_id)
        return is_rate_limited if is_rate_limited
        rate_limit = @instagram_identity.rate_limits.relationships.first
        response = self.class.post("/users/#{api_user_id}/relationship", body: {
          access_token: @instagram_identity.token,
          action: action_name
        })
        rate_limit.increment_request_count!
        process(rate_limit, response)
      end
    end
  end
end
