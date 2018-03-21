namespace :stats do
  desc "Rake task to get stats data"
  task fetch: :environment do
    InstagramIdentity.all.each do |identity|
      Instagram::StatsJob.perform_later(instagram_identity_id: identity.id)
      Rails.logger.info "Queued stats fetch for instagram_identity #{identity.id}"
    end
  end
end
