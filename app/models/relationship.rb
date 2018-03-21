class Relationship < ActiveRecord::Base
  # enum outgoing_status: ["follows", "requested"]
  # enum incoming_status: ["followed_by", "requested_by", "blocked_by_you"]

  belongs_to :user
end
