class IsothermsController < ApplicationController
  skip_forgery_protection only: [:upload]
  before_action :set_isotherm, only: [:show]
  before_action :verify_access, only: [:upload]

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
    @mof = Mof.find params[:mof_id].to_i

    @isotherm = Isotherm.new(mof: @mof,
                             doi: params[:doi],
                             digitizer: params[:digitizer],
                             temp: params[:temp],
                             simin: params[:simin],
                             adsorbate_forcefield: Forcefield.find_by(name: params[:adsorbate_forcefield]),
                             molecule_forcefield: Forcefield.find_by(name: params[:molecule_forcefield]),
                             adsorption_units_id: Classification.find_by(name: params[:adsorption_units]).id,
                             pressure_units_id: Classification.find_by(name: params[:pressure_units]).id,
                             composition_type_id: Classification.find_by(name: params[:composition_type]).id)

    @isotherm.save!

    # points [inchikey, pressure, loading, bulk_comp]
    JSON.parse(params[:points]).each do |isodatum|
      gas_name = isodatum[0]
      gas = Gas.find_by(formula: gas_name)

      if gas.nil?
        syn = Synonym.find_by(name: gas_name)
        gas = syn.gas unless syn.nil?
      end
      if gas.nil?
        gas = Gas.find_by(name: gas_name)
      end
      if gas.nil?
        gas = Gas.find_by(inchikey: gas_name)
      end
      if gas.nil?
        gas = Gas.find_by(inchicode: gas_name)
      end

      datum = Isodatum.new(
          isotherm: @isotherm,
          gas: gas,
          pressure: isodatum[1],
          loading: isodatum[2],
          bulk_composition: isodatum[3])
      datum.save!
    end
    render :json => {id: @isotherm.id}
    @isotherm.destroy! if @isotherm.isodata.count == 0 or @isotherm.is_duplicate
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_isotherm
    @isotherm = Isotherm.find(params[:id])
  end
end
