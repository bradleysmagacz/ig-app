class Hashtag < ActiveRecord::Base
  belongs_to :hashtaggable, polymorphic: true

  after_save :clean_up!

  validates_format_of :name, with: HashtagHelper.hashtag_regex

  protected

  def clean_up!
    unless auto_follow_on? || auto_like_on?
      destroy!
    end
  end
end
