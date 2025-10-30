class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # def user_not_authorized
  # flash[:alert] = "You don't have permission to access this section."
  # end

  def access_denied(exception)
    redirect_to root_path, alert: exception.message
  end
end
