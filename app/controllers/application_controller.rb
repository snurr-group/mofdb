class ApplicationController < ActionController::Base

  def verify_access
    unless params[:passkey] ==  Rails.application.credentials.api_passkey
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end

end
