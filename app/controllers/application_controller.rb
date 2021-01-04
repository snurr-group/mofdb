class ApplicationController < ActionController::Base
  include UnitsHelper
  before_action :checkUnitsValid
  before_action :setHeaders

  def setHeaders
    headers = {'Referrer-Policy' => 'same-origin',
        'X-Content-Type-Options' => 'nosniff',
        'X-Frame-Options' => 'SAMEORIGIN',
        'X-XSS-Protection' => '1; mode=block',
        'Feature-Policy' => "accelerometer 'none'; ambient-light-sensor 'none'; autoplay 'none'; camera 'none'; encrypted-media 'none'; fullscreen 'self'; geolocation 'none'; gyroscope 'none'; magnetometer 'none'; microphone 'none'; midi 'none'; payment 'none'; picture-in-picture 'none'; speaker 'self'; sync-xhr 'none'; usb 'none'; vr 'none'"}
    headers.each do |k,v|
      response.set_header(k,v)
    end
  end


  def cache
    expires_in 1.day, public: true
  end

  def verify_access
    unless params[:passkey] ==  Rails.application.credentials.api_passkey
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end


  def checkUnitsValid
    # If units aren't valid nil them out
    if session[:prefUnits] != nil && !supportedUnits.include?(session[:prefUnits])
      session[:prefUnits] = nil
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
