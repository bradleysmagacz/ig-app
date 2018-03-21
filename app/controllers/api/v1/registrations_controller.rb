class Api::V1::RegistrationsController < Devise::RegistrationsController  
  include ApplicationHelper

  before_action :configure_permitted_parameters 

  respond_to :json

  protected

  def configure_permitted_parameters
    keys = [:email, :full_name]
    devise_parameter_sanitizer.permit(:sign_up, keys: keys)
    devise_parameter_sanitizer.permit(:account_update, keys: keys) 
  end
end  
