class ClassificationsController < ApplicationController

  def index
    nodes = Classification.all.map do |c|
      {name: c.name, type: c.source}
    end
    render :json => nodes
  end

end
