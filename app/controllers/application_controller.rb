class ApplicationController < ActionController::Base
  protect_from_forgery
 # after_filter :flash_to_headers

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  def flash_to_headers
    return unless request.xhr?
    response.headers['X-Message'] = flash[:error]  unless flash[:error].blank?
    # repeat for other flash types...

    flash.discard  # don't want the flash to appear when you reload page
  end
end
