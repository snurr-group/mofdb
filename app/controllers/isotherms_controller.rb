class IsothermsController < ApplicationController
  skip_forgery_protection only: [:upload]
  before_action :set_isotherm, only: [:show]
  before_action :verify_access, only: [:upload]
  before_action :cache, except: [:upload]

  def index
    if params[:mof_id]
      @isotherms = Mof.find(params[:mof_id]).isotherms
    elsif params[:mof_hashkey]
      @isotherms = Mof.find_by(hashkey: params[:mof_hashkey]).isotherms
    else
      @isotherms = Isotherm.all
      @page = params['page'].to_i # nil -> 0
      @page = 1 if @page == 0
      offset = (ENV['PAGE_SIZE'].to_i)*(@page-1)
      @pages = (@isotherms.size.to_f / ENV['PAGE_SIZE'].to_f).ceil
      if offset > @isotherms.size
        return render :json => {"error": "Page number too large"}, status: 400
      end
      @isotherms = @isotherms.offset(offset).take(ENV['PAGE_SIZE'])
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
        ans = Classification.find_by(name: name)
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
        return gas
      end
    end

    @isotherm = Isotherm.new(mof: @mof,
                             batch: Batch.find(params[:batch].to_i),
                             doi: params[:doi],
                             digitizer: params[:digitizer],
                             temp: params[:temp],
                             simin: params[:simin],
                             adsorbate_forcefield: ff_cache(params[:adsorbent_forcefield]),
                             molecule_forcefield: ff_cache(params[:molecule_forcefield]),
                             adsorption_units: classification_cache(params[:adsorption_units]),
                             pressure_units: classification_cache(params[:pressure_units]),
                             composition_type: classification_cache(params[:composition_type]))

    @isotherm.save!

    # points [inchikey, pressure, loading, bulk_comp]
    points = []
    JSON.parse(params[:points]).each do |isodatum|
      next if isodatum[2].downcase == "na" || isodata[2].downcase == "null"
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
    @mof.regen_json

    if @isotherm.isodata.size == 0 # or @isotherm.is_duplicate
      @isotherm.destroy!
      return render :json => {status: "failed", msg: "zero point isotherm"}, status: 500
    end
    return render :json => {status: "success", isotherm_id: @isotherm.id}, status: 200

  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_isotherm
    @isotherm = Isotherm.find(params[:id])
  end
end
