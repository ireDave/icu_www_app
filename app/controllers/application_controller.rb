class ApplicationController < ActionController::Base
  include SessionsHelper
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    logger.warn "Access denied for #{exception.action} #{exception.subject} by user #{current_user.id} from #{request.ip}"
    redirect_to sign_in_path, alert: t("user.unauthorized")
  end
end
