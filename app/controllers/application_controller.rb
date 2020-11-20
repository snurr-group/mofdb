class ApplicationController < ActionController::Base
  include UnitsHelper

  def cache
    expires_in 1.day, public: true
  end

  def verify_access
    unless params[:passkey] ==  Rails.application.credentials.api_passkey
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end

  def setUnits
    units = params[:units]
    if units == "native"
      session[:prefUnits] = nil
      return render json: {units: nil}, status: 200
    end
    if supportedUnits.include?(units)
      session[:prefUnits] = units
      return render json: {units: units}, status: 200
    end
    return render json: {units: units}, status: 500
  end

end
