class ApplicationController < ActionController::Base

  def verify_access
    unless params[:passkey] == ENV['passkey']
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end

end
