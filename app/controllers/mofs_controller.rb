require 'zip'
require 'zip_tricks'
require "base64"
require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper
include MofsHelper

class MofsController < ApplicationController
  include ActionController::Live

  before_action :set_mof, only: [:show, :cif]
  skip_forgery_protection only: [:upload]
  before_action :verify_access, only: [:upload]
  before_action :cache, except: [:upload]

  def count
    # Finding the count of MOFs is the slowest part of the search
    # to speedup the frontend we decouple this from main search query
    # into a separate request to /mofs/count?normal_query_params
    @mofs = filter_mofs(Mof.all.visible.distinct)
    @status = "success"
    @error_message = ""
    begin
      @count = Rails.cache.fetch("mof-count-params-#{params_key}") do
        @mofs.optimizer_hints("MAX_EXECUTION_TIME(10000)", "max_execution_time(10000)").count
      end
    rescue ActiveRecord::StatementTimeout
      @count = nil
      @status = "failed"
      @error_message = "> 100,000"
    end
    @pages = (@count.to_f / ENV['PAGE_SIZE'].to_f).ceil
  end

  # GET /
  def homepage
  end

  # GET /mofs
  # GET /mofs.json
  def index
    @mofs = Mof.all.visible.distinct
    @mofs = filter_mofs(@mofs)

    bulk = params[:bulk] && params[:bulk] == "true"
    cifs = params[:cifs] && params[:cifs] == "true"

    if bulk
      send_zip_file(@mofs, @convert_pressure, @convert_loading, cifs = true, json = true)
      return
    elsif cifs
      send_zip_file(@mofs, @convert_pressure, @convert_loading, cifs = true, json = false)
    end

    respond_to do |format|
      format.json {
        @mofs = @mofs.includes([:elements, :elements_mofs, :batch, :database])
        @page = params['page'].to_i # nil -> 0
        @page = 1 if @page == 0
        offset = (ENV['PAGE_SIZE'].to_i) * (@page - 1)
        @count = Rails.cache.fetch("mof-count-params-#{params_key}") do
          @mofs.count
        end
        @pages = (@count.to_f / ENV['PAGE_SIZE'].to_f).ceil
        if offset > @mofs.size
          return render :json => { error: "Page number too large", pages: @pages }, status: 400
        end
        @mofs = @mofs.offset(offset).take(ENV['PAGE_SIZE'])
      }
      format.html {
        @mofs = @mofs.includes([:elements, :database])
        @mofs = @mofs.take(100)
        return render partial: 'mofs/rows'
      }
    end

  end

  def upload
    modified_params = mof_params
    name = modified_params[:name]

    begin
      elements = JSON.parse(params[:atoms]).map { |atm| Element.find_by(symbol: atm == "x" ? "Xe" : atm) }
      modified_params[:elements] = elements
    rescue
    end

    modified_params = modified_params.except(:atoms)

    if modified_params.include?(:batch)
      modified_params[:batch] = Batch.find(modified_params[:batch])
    end

    if modified_params[:database] == "hMOFs"
      modified_params[:database] = "hMOF"
    end

    database = Database.find_by(name: modified_params[:database])
    modified_params[:database] = database

    @mof = Mof.visible.find_by(name: name, database: database)

    if @mof.nil?
      @mof = Mof.new(modified_params)
      @mof.save!
    else
      @mof.update(modified_params.except(:batch))
    end
    @mof.regen_json
    render status: 200, json: @mof.id.to_json
  end

  # GET /mofs/1
  # GET /mofs/1.json
  def show
    unless @mof.convertable
      @msg = "This mof is missing molarMass or volume and thus we cannot do automatic unit conversion"
    end

    if @mof.isotherms.not_heats.convertable.size != @mof.isotherms.not_heats.size
      @msg = "Some isotherms for this mof use units we do not know how to convert"
    end
  end

  # GET /mofs/1/cif
  def cif
    begin
      if @mof.hidden
        return render status: 403, json: "Unavailable for CSD cifs, see: https://www.ccdc.cam.ac.uk/solutions/csd-system/components/csd/".to_json
      end
      temp_name = "cif-#{SecureRandom.hex(8)}.cif"
      temp_path = Rails.root.join(Rails.root.join("tmp"), temp_name)
      File.open(temp_path, 'w+') do |file|
        file.write(@mof.cif)
      end
      send_data(temp_path.read, filename: @mof.name + ".cif")
    rescue
      raise
    ensure
      File.delete(temp_path)
    end
  end

  # GET /api
  def api
  end

  # GET /databases
  def databases
    @combinations = get_db_doi_gas_combos
    @groups = {} # category => array of files
    DatabaseFile.all.each do |file|
      if @groups.keys.include?(file.category)
        @groups[file.category] << file
      else
        @groups[file.category] = [file]
      end
    end
  end

  private

  def filter_mofs(mofs)

    ## Elements in MOF
    if params[:elements] && params[:elements] != ""
      el_ids = parse_element_ids(params[:elements]) # [12, 73, ...]
      list = Mof.sanitize_sql(el_ids.join(","))
      mofs = mofs.joins("INNER JOIN elements_mofs as el_mof on el_mof.mof_id = mofs.id and el_mof.element_id in (#{list})")
    end

    ## GASES
    if params[:gases] && !params[:gases].empty?
      gases = params[:gases].is_a?(String) ? params[:gases].split(",") : params[:gases]
      gas_ids = gases.map { |gas_name| Gas.find_gas(gas_name).id }.uniq
      mofs = mofs.joins(:isotherms).joins(:isodata).where("isodata.gas_id in (?)", gas_ids)
    end

    ## VOID FRAC
    if params[:vf_min] && !params[:vf_min].empty? && params[:vf_min] && params[:vf_min].to_f != 0
      mofs = mofs.where("mofs.void_fraction >= ?", params[:vf_min])
    end

    if params[:vf_max] && !params[:vf_max].empty? && params[:vf_max].to_f != 1
      mofs = mofs.where("mofs.void_fraction <= ?", params[:vf_max])
    end

    ### PLD
    if params[:pld_min] && !params[:pld_min].empty? && params[:pld_min].to_f != 0
      mofs = mofs.where("mofs.pld >= ?", params[:pld_min])
    end

    if params[:pld_max] && !params[:pld_max].empty? && params[:pld_max].to_f != 20
      mofs = mofs.where("mofs.pld <= ?", params[:pld_max])
    end

    ### LCD
    if params[:lcd_min] && !params[:lcd_min].empty? && params[:lcd_min].to_f != 0
      mofs = mofs.where("mofs.lcd >= ?", params[:lcd_min])
    end

    if params[:lcd_max] && !params[:lcd_max].empty? && params[:lcd_max].to_f != 100
      mofs = mofs.where("mofs.lcd <= ?", params[:lcd_max])
    end

    ### SA M2G
    if params[:sa_m2g_min] && !params[:sa_m2g_min].empty? && params[:sa_m2g_min].to_f != 0
      mofs = mofs.where("mofs.surface_area_m2g >= ?", params[:sa_m2g_min])
    end

    if params[:sa_m2g_max] && !params[:sa_m2g_max].empty? && params[:sa_m2g_max].to_f != 10000
      mofs = mofs.where("mofs.surface_area_m2g <= ?", params[:sa_m2g_max])
    end

    ### SA M2G
    if params[:sa_m2cm3_min] && !params[:sa_m2cm3_min].empty? && params[:sa_m2cm3_min].to_f != 0
      mofs = mofs.where("mofs.surface_area_m2cm3 >= ?", params[:sa_m2cm3_min])
    end

    if params[:sa_m2cm3_max] && !params[:sa_m2cm3_max].empty? && params[:sa_m2cm3_max].to_f != 5000
      mofs = mofs.where("mofs.surface_area_m2cm3 <= ?", params[:sa_m2cm3_max])
    end

    # NAME
    if params[:name] && !params[:name].empty?
      mofs = mofs.where("mofs.name LIKE ?", "#{params[:name]}%")
    end

    # DB
    if params[:database] && params[:database] != "Any" && !params[:database].empty?
      database = Database.find_by(name: params[:database])
      mofs = mofs.where(database: database)
    end

    # Hashkey
    if params[:hashkey] && !params[:hashkey].empty?
      mofs = mofs.where(hashkey: params[:hashkey])
    end

    if params[:mofid] && !params[:mofid].empty?
      mofs = mofs.where(mofid: params[:mofid])
    end

    if params[:mofkey] && !params[:mofkey].empty?
      mofs = mofs.where(mofkey: params[:mofkey])
    end

    if params[:doi] && !params[:doi].empty?
      mofs = mofs.joins("JOIN isotherms on isotherms.mof_id = mofs.id")
                 .where("isotherms.doi = ?", params[:doi]).distinct
    end

    mofs
  end

  def set_mof
    @mof = Mof.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def mof_params
    params.require(:mof).permit(:atoms, :mof, :batch, :mofkey, :mofid, :hashkey, :name, :database, :cif,
                                :void_fraction, :surface_area_m2g, :surface_area_m2cm3, :pld, :lcd, :pxrd, :pore_size_distribution)
  end

  def params_key
    # All API parameters except those that don't effect the results only the format
    # This way we can use it as a cache key pointing to the number of mofs returuned.
    # Counting the number of results is more expensive than returning 1 page of them
    # so it's important to cahce the count.
    # See the count function.
    params.except(:page).except(:html).except(:bulk).to_s
  end

end
