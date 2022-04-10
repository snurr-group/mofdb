class ClassificationsController < ApplicationController

  def index
    expires_in 0.seconds, public: true
    nodes = Classification.all.map do |c|
      {name: c.name, type: c.source}
    end
    render :json => nodes
  end

end
