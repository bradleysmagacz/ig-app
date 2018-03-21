class InstagramIdentity < ActiveRecord::Base
  after_create :seed_rate_limits
  after_create :seed_stats

  belongs_to :user
  has_many :rate_limits, as: :identifiable, class_name: 'Instagram::RateLimit'
  has_many :hashtags, as: :hashtaggable
  has_many :stats, as: :stattable

  has_secure_token :token
  has_attached_file :profile_picture,
    url: "/assets/:rails_env/:class/:id/:attachment/:style:dotextension",
    styles: { small: "100x100" }

  validates_attachment_content_type :profile_picture, :content_type => ["image/jpg", "image/jpeg", "image/png"]

  def is_rate_limited?
    rate_limits.map(&:is_rate_limited?).any?
  end

  def stats_breakdown
    last_year_stat = stats.last_year.first || Stat.new
    last_month_stat = stats.last_month.first || Stat.new
    last_week_stat = stats.last_week.first || Stat.new
    yesterday_stat = stats.yesterday.first || Stat.new
    today_stat = stats.today.first || Stat.new
    Stat.keys.map { |attr|
      [attr, {
        year: today_stat[attr] - last_year_stat[attr],
        month: today_stat[attr] - last_month_stat[attr],
        week: today_stat[attr] - last_week_stat[attr],
        today: today_stat[attr] - yesterday_stat[attr]
      }]
    }.to_h
  end

  private

  def seed_rate_limits
    slugs = Instagram::RateLimit.all_slugs
    slugs.each do |slug|
      Instagram::RateLimit.where(identifiable: self, slug: slug).first_or_create! do |rate_limit|
        if slug == "global"
          rate_limit.hourly_limit = Rails.env.development? ? 499 : 4999
        else
          rate_limit.hourly_limit = Rails.env.development? ? 29 : 59
        end
      end
    end
  end

  def seed_stats
    Instagram::StatsJob.perform_async(instagram_identity_id: self)
  end
end
