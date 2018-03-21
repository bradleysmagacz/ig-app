module HashtagHelper
  def is_valid_hashtag?(hashtag="")
    hashtag.scan(HashtagHelper.hashtag_regex).count > 0
  end

  def self.hashtag_regex
    /(^[a-z0-9_]{2,15}$)/i 
  end
end
