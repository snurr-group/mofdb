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
      if params[:limit]
        @isotherms = Isotherm.all.take(100)
      else
        @isotherms = Isotherm.all.take(params[:limit].to_i)
      end
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
        gas = Gas.find_by(name: name)
        if gas.nil?
          gas = Gas.find_by(formula: name)
        end
        if gas.nil?
          syn = Synonym.find_by(name: name)
          gas = syn.gas unless syn.nil?
        end
        if gas.nil?
          gas = Gas.find_by(inchikey: name)
        end
        if gas.nil?
          gas = Gas.find_by(inchicode: name)
        end
        Rails.cache.write(key, gas, expires_in: 1.hours)
        return gas
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
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_isotherm
    @isotherm = Isotherm.find(params[:id])
  end
end
