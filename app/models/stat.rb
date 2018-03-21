class Stat < ActiveRecord::Base
  belongs_to :stattable, polymorphic: true

  scope :last_year, -> {
    date = (Time.zone.now - 1.year).beginning_of_day
    where("created_at >= ? AND created_at <= ?", date - 3, date + 3.month).order(:created_at)
  }
  scope :last_month, -> {
    date = (Time.zone.now - 1.month).beginning_of_day
    where("created_at >= ? AND created_at <= ?", date - 1.week, date + 1.week).order(:created_at)
  }
  scope :last_week, -> {
    date = (Time.zone.now - 1.week).beginning_of_day
    where("created_at >= ? AND created_at <= ?", date - 3.5.day, date + 3.5.day).order(:created_at)
  }
  scope :yesterday, -> {
    date = (Time.zone.now - 1.day).beginning_of_day 
    where("created_at >= ? AND created_at <= ?", date - 1.day, date + 1.day).order(:created_at)
  }
  scope :today, -> { order(created_at: :desc) }

  def self.keys
    [:num_media, :num_follows, :num_followed_by, :num_likes_received,
     :num_likes_sent, :num_comments_received, :num_comments_sent]
  end
end
