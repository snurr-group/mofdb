require 'zip'
require 'zip_tricks'
require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

class MofsController < ApplicationController
  include ActionController::Live

  before_action :set_mof, only: [:show, :cif]
  skip_forgery_protection only: [:upload]
  before_action :verify_access, only: [:upload]
  before_action :cache, except: [:upload]

  # GET /mofs
  # GET /mofs.json
  def index
    visible = Mof.all.visible
    if request.path == "/"
      # If there are no filters just render the html view
      return render 'index'
    end
    if params[:html]
      @mofs = visible.includes(:database, :elements, :gases)
    elsif params[:bulk] && params[:bulk] == 'true'
      @mofs = visible
    else
      # Fallback
      respond_to do |format|
        format.html { @mofs = visible.includes(:database) }
        format.json { @mofs = visible }
      end
    end

    begin
      filter_mofs
    rescue PageTooLarge
      return render :json => {"error": "Page number too large"}, status: 400
    end

    response.headers['mofdb-count'] = @count
    response.headers['mofdb-pages'] = (@count.to_f / ENV['PAGE_SIZE'].to_f).ceil
    if params[:html]
      render partial: 'mofs/rows'
      return
    end

    # If params[:bulk]
    if params[:bulk] && params[:bulk] == "true" && @mofs.any?
      csd = Database.find_by(name: "CSD")
      zip_name = "mofs-bulk-search-download.zip"
      send_file_headers!(
          type: "application/zip",
          disposition: "attachment",
          filename: zip_name
      )
      response.headers["Last-Modified"] = Time.now.httpdate.to_s
      response.headers["X-Accel-Buffering"] = "no"

      writer = ZipTricks::BlockWrite.new do |chunk|
        response.stream.write(chunk)
      end

      begin
        ZipTricks::Streamer.open(writer) do |zip|
          @mofs = @mofs.select("id, pregen_json, name, cif, database_id")
          @mofs.in_batches(of: 500).each_record do |mof|
            next if mof.database_id == csd.id
            zip.write_deflated_file("#{mof.name}-(id:#{mof.id}).cif") do |file_writer|
              file_writer << mof.cif
            end
            zip.write_deflated_file("#{mof.name}-(id:#{mof.id}).json") do |file_writer|
              file_writer << mof.pregen_json.to_json
            end
          end
        end
      ensure
        puts "closing stream"
        response.stream.close
        return
      end

    end

    respond_to do |format|
      format.html {
        # Render the index.html.erb template
      }
      format.json {
        # Instead of generating json on the fly we store it in a pre-generated column and just concat those columns
        render :json => @mofs.pluck(:pregen_json)
      }
    end

  end

  def upload
    # Used by the mofdb_upload (on github) to add a new mof
    hashkey = params[:hashkey]
    name = params[:name]
    @mof = Mof.visible.find_by(name: name)
    begin
      elements = JSON.parse(params[:atoms]).map { |atm| Element.find_by(symbol: atm == "x" ? "Xe" : atm) }
      mof_params[:elements] = elements
    rescue
    end

    mof_params = {name: params[:name],
                  hashkey: params[:hashkey],
                  cif: params[:cif],
                  void_fraction: params[:void_fraction],
                  surface_area_m2g: params[:surface_area_m2g],
                  surface_area_m2cm3: params[:surface_area_m2cm3],
                  pld: params[:pld],
                  lcd: params[:lcd],
                  pxrd: params[:pxrd],
                  mofkey: params[:mofkey],
                  mofid: params[:mofid],
                  pore_size_distribution: params[:pore_size_distribution]}

    if params[:db] == "hMOFs"
      mof_params[:database] = Database.find_by(name: "hMOF")
    else
      mof_params[:database] = Database.find_by(name: params[:db])
    end


    if @mof.nil?
      @mof = Mof.new(mof_params)
      @mof.save!
    else
      non_nil_params = {}
      mof_params.each do |key, value|
        if value.nil? || value.is_a?(String) && value.empty?
        else
          non_nil_params[key] = value
        end
        @mof.update(non_nil_params)
      end

    end
    @mof.regen_json
    render status: 200, json: @mof.id.to_json

  end

  # GET /mofs/1
  # GET /mofs/1.json
  def show
  end

  # GET /mofs/1/cif
  def cif
    if @mof.database.name == "CSD"
      return render status: 403, json: "Unavailable for CSD cifs, see: https://www.ccdc.cam.ac.uk/solutions/csd-system/components/csd/".to_json
    end
    temp_name = "cif-#{SecureRandom.hex(8)}.cif"
    temp_path = Rails.root.join(Rails.root.join("tmp"), temp_name)
    File.open(temp_path, 'w+') do |file|
      file.write(@mof.cif)
    end
    send_data(temp_path.read, filename: @mof.name + ".cif")
    File.delete(temp_path)
  end

  # GET /api
  def api
  end

  # GET /databases
  def databases
    @combinations = get_db_doi_gas_combos
  end


  private

  def filter_mofs

    ## Elements in MOF
    if params[:elements] && params[:elements] != ""
      el_ids = params[:elements].map { |el| Element.find_by(symbol: el).id }
      query = "SELECT DISTINCT elements_mofs.mof_id from elements_mofs
              where element_id in (?)"
      sanitized = ActiveRecord::Base.send(:sanitize_sql_array, [query, el_ids])
      mof_ids = ActiveRecord::Base.connection.execute(sanitized).to_a.flatten
      @mofs = @mofs.where("mofs.id in (?)", mof_ids)
    end

    ## GASES
    if params[:gases] && !params[:gases].empty?
      gases = params[:gases].is_a?(String) ? [params[:gases]] : params[:gases] # put a string in an array so we can map it  below
      gas_ids = gases.map { |gas_name| Gas.find_gas(gas_name).id }.uniq
      # This was really slow without the custom sql.
      query = "SELECT DISTINCT mofs.id from isodata
              INNER JOIN isotherms on isotherms.id = isodata.isotherm_id
              INNER JOIN mofs on mofs.id = isotherms.mof_id
              where gas_id in (?)"
      sanitized = ActiveRecord::Base.send(:sanitize_sql_array, [query, gas_ids])
      mof_ids = ActiveRecord::Base.connection.execute(sanitized).to_a.flatten
      # Now we have the ids of all the mofs with this gas_id in their isodata.
      # In order to be compatible with the filter method below we return to the active record
      # interface. This is an extra query sadly.
      @mofs = @mofs.where("mofs.id in (?)", mof_ids).includes(:database, :elements)
    end

    ## VOID FRAC
    if params[:vf_min] && !params[:vf_min].empty? && params[:vf_min] && params[:vf_min].to_f != 0
      @mofs = @mofs.where("mofs.void_fraction >= ?", params[:vf_min])
    end

    if params[:vf_max] && !params[:vf_max].empty? && params[:vf_max].to_f != 1
      @mofs = @mofs.where("mofs.void_fraction <= ?", params[:vf_max])
    end

    ### PLD
    if params[:pld_min] && !params[:pld_min].empty? && params[:pld_min].to_f != 0
      @mofs = @mofs.where("mofs.pld >= ?", params[:pld_min])
    end


    if params[:pld_max] && !params[:pld_max].empty? && params[:pld_max].to_f != 20
      @mofs = @mofs.where("mofs.pld <= ?", params[:pld_max])
    end

    ### LCD
    if params[:lcd_min] && !params[:lcd_min].empty? && params[:lcd_min].to_f != 0
      @mofs = @mofs.where("mofs.lcd >= ?", params[:lcd_min])
    end

    if params[:lcd_max] && !params[:lcd_max].empty? && params[:lcd_max].to_f != 100
      @mofs = @mofs.where("mofs.lcd <= ?", params[:lcd_max])
    end

    ### SA M2G
    if params[:sa_m2g_min] && !params[:sa_m2g_min].empty? && params[:sa_m2g_min].to_f != 0
      @mofs = @mofs.where("mofs.surface_area_m2g >= ?", params[:sa_m2g_min])
    end

    if params[:sa_m2g_max] && !params[:sa_m2g_max].empty? && params[:sa_m2g_max].to_f != 10000
      @mofs = @mofs.where("mofs.surface_area_m2g <= ?", params[:sa_m2g_max])
    end

    ### SA M2G
    if params[:sa_m2cm3_min] && !params[:sa_m2cm3_min].empty? && params[:sa_m2cm3_min].to_f != 0
      @mofs = @mofs.where("mofs.surface_area_m2cm3 >= ?", params[:sa_m2cm3_min])
    end

    if params[:sa_m2cm3_max] && !params[:sa_m2cm3_max].empty? && params[:sa_m2cm3_max].to_f != 5000
      @mofs = @mofs.where("mofs.surface_area_m2cm3 <= ?", params[:sa_m2cm3_max])
    end

    # NAME
    if params[:name] && !params[:name].empty?
      @mofs = @mofs.where("mofs.name LIKE ?", "#{params[:name]}%")
    end

    # DB
    if params[:database] && params[:database] != "Any" && !params[:database].empty?
      database = Database.find_by(name: params[:database])
      @mofs = @mofs.where(database: database)
    end

    # Hashkey
    if params[:hashkey] && !params[:hashkey].empty?
      @mofs = @mofs.where(hashkey: params[:hashkey])
    end

    if params[:mofid] && !params[:mofid].empty?
      mofid = ActiveRecord::Base.connection.quote(params[:mofid].to_s)
      @mofs = @mofs.where("MATCH (mofs.mofid) AGAINST (#{mofid})")
    end

    if params[:mofkey] && !params[:mofkey].empty?
      mofkey = ActiveRecord::Base.connection.quote(params[:mofkey].to_s)
      @mofs = @mofs.where("MATCH (mofs.mofkey) AGAINST (#{mofkey})")
    end

    if params[:doi] && !params[:doi].empty?
      @mofs = @mofs.includes(:isotherms).where("isotherms.doi = (?)", params[:doi]).references(:isotherms)
    end

    @count = Rails.cache.fetch("mofcount-paramsp-#{params.to_s}") do
      @mofs.count
    end

    respond_to do |format|
      format.html {
        @mofs = @mofs.take(100)
      }
      format.json {
        unless params[:bulk] && params[:bulk] == 'true'
          page = params['page'].to_i # nil -> 0
          page = 1 if page == 0
          offset = (ENV['PAGE_SIZE'].to_i) * (page - 1)
          raise PageTooLarge if offset > @mofs.size
          @mofs = @mofs.offset(offset).take(ENV['PAGE_SIZE'])
        end
      }
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_mof
    @mof = Mof.visible.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def mof_params
    params.require(:mof).permit(:hashkey, :name, :db, :cif, :void_fraction, :surface_area_m2g, :surface_area_m2cm3, :pld, :lcd, :pxrd, :pore_size_distribution)
  end

end