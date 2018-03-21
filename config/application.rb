require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module InstaBot
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    
    config.action_cable.log_tags = [
      -> request { request.params[:email] || "no-email" },
      :action_cable,
      -> request { request.uuid }
    ]
    config.action_cable.mount_path = '/connect'

    config.action_dispatch.default_headers = {
      'Access-Control-Allow-Origin' => 'https://57ee18e0.ngrok.io',
      'Access-Control-Request-Method' => %w{GET POST OPTIONS DELETE HEAD PUT}.join(",")
    }

    config.active_job.queue_adapter = :sidekiq
  end
end
