class ApplicationController < ActionController::Base
  include UnitsHelper
  before_action :setPreferredUnits
  before_action :setHeaders

  def setHeaders
    headers = { 'Referrer-Policy' => 'same-origin',
                'X-Content-Type-Options' => 'nosniff',
                'X-Frame-Options' => 'SAMEORIGIN',
                'X-XSS-Protection' => '1; mode=block',
                'Feature-Policy' => "accelerometer 'none'; ambient-light-sensor 'none'; autoplay 'none'; camera 'none'; encrypted-media 'none'; fullscreen 'self'; geolocation 'none'; gyroscope 'none'; magnetometer 'none'; microphone 'none'; midi 'none'; payment 'none'; picture-in-picture 'none'; speaker 'self'; sync-xhr 'none'; usb 'none'; vr 'none'" }
    headers.each do |k, v|
      response.set_header(k, v)
    end
  end

  def cache
    expires_in 1.day, public: true
  end

  def verify_access
    unless params[:passkey] == Rails.application.credentials.api_passkey
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end

  def setPreferredUnits

    loading = request.headers['loading']
    pressure = request.headers['pressure']
    if loading
      if loading == "native"
        session[:prefLoading] = nil
      else
        loading = Classification.find(request.headers['loading'])
        session[:prefLoading] = loading.id
      end
    end
    if pressure
      if pressure == "native"
        session[:prefPressure] = nil
      else
        pressure = Classification.find(request.headers['pressure'])
        session[:prefPressure] = pressure.id
      end
    end
  end

  def setUnits
    # checkUnits applies header values to session.
    # this route just jsonifyies units after that.
    render json: { loading: session[:prefLoading], pressure: session[:prefPressure] }, status: 200
  end

end
