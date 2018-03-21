module ApplicationHelper
  def render_unauthorized
    render status: :unauthorized, json: { error: "You need to sign in before continuing." }
  end
end
