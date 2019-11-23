class IsothermsController < ApplicationController
  skip_forgery_protection only: [:upload]
  before_action :set_isotherm, only: [:show]
  before_action :verify_access, only: [:upload]

  def index

    if params[:mof_id]
      @isotherms = Mof.find(params[:mof_id]).isotherms
    elsif params[:mof_hashkey]
      @isotherms = Mof.find_by(hashkey: params[:mof_hashkey]).isotherms
    else
      page = params['page'].to_i # nil -> 0
      page = 1 if page == 0
      @isotherms = Isotherm.offset(ENV['PAGE_SIZE'] * (page-1)).take(ENV['PAGE_SIZE'])
    end
  end

  def show
  end

  def upload
    @mof = Mof.find params[:mof_id].to_i

    def classification_cache(name)
      key = "classification-" + name
      if Rails.cache.exist?(key)
        return Rails.cache.fetch(key)
      else
        ans = Classification.find_by(name: name).id
        Rails.cache.write(key, ans, expires_in: 1.hours)
        return ans
      end
    end

    def ff_cache(name)
      key = "ff-" + name
      if Rails.cache.exist?(key)
        return Rails.cache.fetch(key)
      else
        ans = Forcefield.find_by(name: name)
        Rails.cache.write(key, ans, expires_in: 1.hours)
        return ans
      end
    end

    def gas_cache(name)
      key = "gas-" + name
      if Rails.cache.exist?(key)
        return Rails.cache.fetch(key)
      else
        gas = Gas.find_gas(name)
        Rails.cache.write(key, gas, expires_in: 1.hours)
      end
    end

    @isotherm = Isotherm.new(mof: @mof,
                             doi: params[:doi],
                             digitizer: params[:digitizer],
                             temp: params[:temp],
                             simin: params[:simin],
                             adsorbate_forcefield: ff_cache(params[:adsorbate_forcefield]),
                             molecule_forcefield: ff_cache(params[:molecule_forcefield]),
                             adsorption_units_id: classification_cache(params[:adsorption_units]),
                             pressure_units_id: classification_cache(params[:pressure_units]),
                             composition_type_id: classification_cache(params[:composition_type]))

    @isotherm.save!

    # points [inchikey, pressure, loading, bulk_comp
    points = []
    JSON.parse(params[:points]).each do |isodatum|
      gas_name = isodatum[0]
      gas = gas_cache(gas_name)

      datum = Isodatum.new(
          isotherm: @isotherm,
          gas: gas,
          pressure: isodatum[1],
          loading: isodatum[2],
          bulk_composition: isodatum[3])
      points << datum
    end

    Isodatum.import points
    render :json => @isotherm.id.to_json
    @isotherm.destroy! if points.size == 0 or @isotherm.is_duplicate
    @mof.regen_json
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_isotherm
    @isotherm = Isotherm.find(params[:id])
  end
end
