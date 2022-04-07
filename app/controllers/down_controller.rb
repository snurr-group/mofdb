class DownController < ApplicationController
  def index
    @maintenance = true
    path = Rails.root.join('tmp', 'down.txt')
    if !File.exists?(path)
      return redirect_to '/'
    end
    begin
      file = File.open(path)
      @message = file.read
    ensure
      file.close
    end
    if params.keys.include?("bypass")
      session[:bypass_maintenance] = true
      return redirect_to '/'
    end
    if params.keys.include?("end_bypass")
      session.delete(:bypass_maintenance)
    end
  end
end