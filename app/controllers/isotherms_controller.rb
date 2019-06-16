class IsothermsController < ApplicationController

  before_action :set_isotherm, only: [:show]
  def index

    if params[:mof_id]
      @isotherms = Mof.find(params[:mof_id]).isotherms
    else
      @isotherms = Isotherm.all
    end
  end

  def show
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_isotherm
    @isotherm = Isotherm.find(params[:id])
  end
end
