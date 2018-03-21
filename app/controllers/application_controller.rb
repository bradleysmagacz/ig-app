class ApplicationController < ActionController::Base
  include ErrorHelper

  # protect_from_forgery with: :exception
end
