set :environment, ENV['RAILS_ENV']
set :output, { error: "log/cron_error_log.log", standard: "log/cron_log.log" }

every 1.day at: '12:00 am' do
  rake "stats:fetch"
end
