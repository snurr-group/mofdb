class ReportsController < ApplicationController
  skip_forgery_protection only: [:create]

  def create
    r_params = report_params
    r_params[:ip] = request.ip
    r = Report.create!(r_params)
    flash[:message] = "Your report has been received."
    begin
      Sentry.capture_message("Report: '#{r.description}' from #{request.ip.to_s}")
    rescue
    end
    return redirect_to '/'
  end

  private

  def report_params
    params.permit(:email, :description)
  end
end

