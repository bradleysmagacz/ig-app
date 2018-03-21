module InstagramDataHelper
  def instagram_users(rate_limit)
    (1..rate_limit.current_limit).map { |index|
      { id: index.to_s }
    }
  end

  def instagram_medias(rate_limit)
    (1..rate_limit.current_limit).map { |index|
      { id: index.to_s }
    }
  end
end
