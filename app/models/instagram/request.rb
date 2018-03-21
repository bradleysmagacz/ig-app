module Instagram
  class Request < ActiveRecord::Base
    belongs_to :rate_limit
  end
end
