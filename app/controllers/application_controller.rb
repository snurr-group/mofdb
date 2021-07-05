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

  def setSessionForHeader(input, session_key, expected_classification_source)
    # Input: What the user sent, either a number representing a classification's id or a string that is it's name
    # session_key: :prefPressure or :prefLoading where to store the final parsed classification id
    # expected_classification_source: either "pressure" or "loading".
    #   Prevents someone setting "pa" as their preferred loading since that's a pressure not a loading
    if input.nil?
      return
    end
    if input == "native" && !session[session_key].nil?
      session.delete(session_key)
    else
      if input.to_i != 0
        classification = Classification.find(input)
      elsif input.is_a?(String)
        classification = Classification.find_by(name: input)
      else
        return render json: {"error": "We don't know what unit '#{input}' is"}, status: 500
      end
      session[session_key] = classification.id
      if classification.source != expected_classification_source
        session.delete(session_key)
        supported = Classification.where(convertable: true, source: expected_classification_source).pluck(:name)
        return render json: {"error": "#{input} is not a known #{expected_classification_source} by id or name. Supported options are #{supported}"}, status: 500
      end
    end
  end

  def setPreferredUnits
    setSessionForHeader(request.headers['loading'], :prefLoading, "loading")
    setSessionForHeader(request.headers['pressure'], :prefPressure, "pressure")
  end

  def setUnits
    # checkUnits applies header values to session.
    # this route just jsonifyies units after that.
    render json: { loading: session[:prefLoading], pressure: session[:prefPressure] }, status: 200
  end

end
