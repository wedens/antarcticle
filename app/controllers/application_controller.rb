class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "You are not authorized for this action"
    redirect_to root_url
  end
end
