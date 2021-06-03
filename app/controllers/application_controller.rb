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

  def setSessionForHeader(input, session_key)
    if input == "native" && !session[session_key].nil?
      session.delete(session_key)
    elsif input.to_i != 0
      session[session_key] = Classification.find(input).id
    elsif input.is_a?(String)
      session[session_key] = Classification.find_by(name: input).id
    end
  end

  def setPreferredUnits
    setSessionForHeader(request.headers['loading'], :prefLoading)
    setSessionForHeader(request.headers['pressure'], :prefPressure)
  end

  def setUnits
    # checkUnits applies header values to session.
    # this route just jsonifyies units after that.
    render json: { loading: session[:prefLoading], pressure: session[:prefPressure] }, status: 200
  end

end
