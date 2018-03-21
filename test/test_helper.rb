ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/mock'

# 3rd party
require 'webmock/minitest'
require 'sidekiq/testing'

# Include helpers
Dir[Rails.root.join("test/helpers/**/*.rb")].each { |f| require f }

WebMock.disable_net_connect!

SimpleCov.start

class ActiveSupport::TestCase
  include InstagramDataHelper
  include StubHelpers

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  # TODO: change to true by default
  def json(symbolize_keys=false)
    JSON.parse response.body, symbolize_names: symbolize_keys
  end

  def set_basic_auth(user)
    @request.headers['X-User-Email'] = user.email
    @request.headers['X-User-Username'] = user.username
    @request.headers['X-User-Token'] = user.authentication_token
  end

  def setup
    Sidekiq::Testing.fake!
  end

  def teardown
    Sidekiq::Worker.clear_all
  end
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include StubHelpers

  def setup
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
end
