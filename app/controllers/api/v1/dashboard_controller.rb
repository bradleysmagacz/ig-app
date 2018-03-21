class Api::V1::DashboardController < Api::V1::BaseController
  def index
    render json: current_user
  end
end
