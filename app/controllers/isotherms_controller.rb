class IsothermsController < ApplicationController

  def index
    @isotherms = Isotherm.all
  end

  def show
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_isotherm
    @isotherm = Isotherm.find(params[:id])
  end
end
