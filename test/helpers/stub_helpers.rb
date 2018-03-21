module StubHelpers
  # body is not used for non-GET requests
  def stub_instagram_request(method=:get, path, instagram_identity)
    access_token = instagram_identity.token
    url = "https://api.instagram.com/v1#{path}"
    if method == :get
      stub_request(method, "#{url}?access_token=#{access_token}")
    else
      stub_request(method, url)
    end
  end
end
