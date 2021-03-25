class ForcefieldsController < ApplicationController

  def index
    render :json => Forcefield.all.pluck(:name).to_a
  end

end
