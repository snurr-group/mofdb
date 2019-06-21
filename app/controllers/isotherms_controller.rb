class IsothermsController < ApplicationController
  skip_forgery_protection only: [:upload]
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

  def upload
    puts "-------------------------"
    puts "-------------------------"
    puts "-------------------------"
    @mof = Mof.find params[:mof_id].to_i

    @isotherm = Isotherm.new(mof: @mof,
                             doi: params[:doi],
                             digitizer: params[:digitizer],
                             temp: params[:temp],
                             simin: params[:simin],
                             forcefield: Forcefield.find_by(name: params[:forcefield]),
                             adsorption_units_id: Classification.find_by(name: params[:adsorption_units]).id,
                             pressure_units_id: Classification.find_by(name: params[:pressure_units]).id,
                             composition_type_id: Classification.find_by(name: params[:composition_type]).id)

    @isotherm.save!

    # points [inchikey, pressure, loading, bulk_comp]
    JSON.parse(params[:points]).each do |isodatum|
      puts "isodatum: "+isodatum[0].inspect
      gas = Gas.find_by(formula: isodatum[0])
      puts "gas: "+gas.inspect
      if gas.nil?
        gas = Synonym.find_by(name: isodatum[0]).gas
        puts "gas: "+gas.inspect
      end
      if gas.nil?
        gas = Gas.find_by(name: isodatum[0])
      end
      datum = Isodatum.new(
          isotherm: @isotherm,
          gas: gas,
          pressure: isodatum[1],
          loading: isodatum[2],
          bulk_composition: isodatum[3])
      datum.save!
    end


  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_isotherm
    @isotherm = Isotherm.find(params[:id])
  end
end
