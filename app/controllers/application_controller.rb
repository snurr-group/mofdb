class ApplicationController < ActionController::Base

  def verify_access
    puts params.inspect
    puts params[:passkey]
    puts ENV['passkey']
    unless params[:passkey] == ENV['passkey']
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
      # raise
    end
  end


end
