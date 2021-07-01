require 'zip'
require 'zip_tricks'
require "base64"
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

    # Finding the count of MOFs is the slowest part of the search
    # to speedup the frontend we decouple this from main search query
    # into a separate request to /mofs/count?normal_query_params

    get_count = request.path == "/mofs/count" || request.format.to_s == "application/json"

    if params[:html] || params[:bulk] && params[:bulk] == 'true'
      @mofs = visible.includes(:database, :elements, :gases, :batch)
    else
      respond_to do |format|
        format.html { @mofs = visible.includes(:database) }
        format.json { @mofs = visible }
      end
    end

    begin
      filter_mofs(get_count)
    rescue PageTooLarge
      return render :json => { error: "Page number too large" }, status: 400
    end

    if get_count
      @pages = (@count.to_f / ENV['PAGE_SIZE'].to_f).ceil
      response.headers['mofdb-count'] = @count
      response.headers['mofdb-pages'] = @pages
    end

    # Render table rows using rails view _rows.html.erb
    return render partial: 'mofs/rows' if params[:html]

    # If params[:bulk]
    if params[:bulk] && params[:bulk] == "true"
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

      @mofs = @mofs.convertable.includes(:isotherms)
                   .includes(:isodata)
                   .includes(:gases)
                   .includes(:adsorbate_forcefields)
                   .includes(:molecule_forcefields)
                   .includes(:adsorption_units)
                   .includes(:pressure_units)
                   .includes(:composition_type)
                   .includes(:batch)

      @convertPressure = session[:prefPressure] ? Classification.find(session[:prefPressure]) : nil
      @convertLoading = session[:prefLoading] ? Classification.find(session[:prefLoading]) : nil
      begin
        ZipTricks::Streamer.open(writer) do |zip|
          @mofs.in_batches(of: 500).each_record do |mof|
            begin
              content = mof.get_json(@convertPressure, @convertLoading)
              cif = mof.cif
              zip.write_deflated_file("#{mof.name}-(id:#{mof.id}).json") do |file_writer|
                file_writer << content
              end
              zip.write_deflated_file("#{mof.name}-(id:#{mof.id}).cif") do |file_writer|
                file_writer << cif
              end
            rescue Exception => e
              next
            end
          end
        end
      rescue Exception => e
        Sentry.capture_message("Error while creating a zip file #{request.url.to_s}")
      ensure
        response.stream.close
        return
      end

    end

    respond_to do |format|
      format.json {
        if request.path == "/mofs/count"
          return render json: { count: @count }
        else

          result = { results: [], pages: @pages, page: @page }
          convertPressure = session[:prefPressure] ? Classification.find(session[:prefPressure]) : nil
          convertLoading = session[:prefLoading] ? Classification.find(session[:prefLoading]) : nil
          if convertPressure.nil? && convertLoading.nil?
            # Instead of generating json on the fly we store it in a pre-generated column and just concat those columns
            result[:results] = @mofs.pluck(:pregen_json)
            return render :json => result
          else
            # In this case we need to convert pressure/Loading on the fly
            @mofs.each do |mof|
              result[:results].append(JSON.parse(mof.get_json(convertPressure, convertLoading)))
            end
            return render :json => result
          end

        end
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
      modified_params[:database] = Database.find_by(name: "hMOF")
    else
      modified_params[:database] = Database.find_by(name: modified_params[:database])
    end

    database = modified_params[:database]

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
    @convertPressure = session[:prefPressure] ? Classification.find(session[:prefPressure]) : nil
    @convertLoading = session[:prefLoading] ? Classification.find(session[:prefLoading]) : nil

    if !@mof.convertable
      @msg = "This mof is missing molarMass or volume and thus we cannot do automatic unit conversion"
    end


    if @mof.isotherms.convertable.size != @mof.isotherms.size
      @msg = "Some isotherms for this mof use units we do not know how to convert"
    end

    respond_to do |format|
      format.html {}
      format.json {
        # I am well aware this is the wrong way to render a view.
        #
        # We do it this way b/c in index route we need to render this same view and we need to pass
        # in @convertPressure/@convertLoading but we cannot easily pass @ variables, only locals using
        # the ApplicationController.render in mof.rb:get_json
        # so by doing it the same ugly way here we at least don't have two different ways of calling
        # that same template.
        json = @mof.get_json(@convertPressure, @convertLoading)
        return render :json => json, status: 200
      }
    end
  end

  # GET /mofs/1/cif
  def cif
    if @mof.hidden
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

  def filter_mofs(get_count)

    ## Elements in MOF
    if params[:elements] && params[:elements] != ""
      el_ids = params[:elements]
      if el_ids.is_a?(String)
        el_ids = [el_ids]
      end
      el_ids = el_ids.map { |el| Element.find_by(symbol: el).id }
      query = "SELECT DISTINCT elements_mofs.mof_id from elements_mofs
              where element_id in (?)"
      sanitized = ActiveRecord::Base.send(:sanitize_sql_array, [query, el_ids])
      mof_ids = ActiveRecord::Base.connection.execute(sanitized).to_a.flatten
      @mofs = @mofs.where("mofs.id in (?)", mof_ids)
    end

    ## GASES
    if params[:gases] && !params[:gases].empty?
      gases = params[:gases].is_a?(String) ? params[:gases].split(",") : params[:gases]
      gas_ids = gases.map { |gas_name| Gas.find_gas(gas_name).id }.uniq
      @mofs = Mof.joins(:isotherms).joins(:isodata).where("isodata.gas_id in (?)", gas_ids).distinct
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
      @mofs = @mofs.where(mofid: params[:mofid])
    end

    if params[:mofkey] && !params[:mofkey].empty?
      @mofs = @mofs.where(mofkey: params[:mofkey])
    end

    if params[:doi] && !params[:doi].empty?
      @mofs = @mofs.joins("JOIN isotherms on isotherms.mof_id = mofs.id and isotherms.doi = '#{Mof.sanitize_sql(params[:doi])}'").distinct
    end

    if get_count
      @count = Rails.cache.fetch("mofcount-params-#{params.to_s}") do
        @mofs.count
      end
    end

    respond_to do |format|
      format.html { @mofs = @mofs.take(100) }
      format.json {
        unless params[:bulk] && params[:bulk] == 'true'
          @page = params['page'].to_i # nil -> 0
          @page = 1 if @page == 0
          offset = (ENV['PAGE_SIZE'].to_i) * (@page - 1)
          raise PageTooLarge if offset > @mofs.size
          @mofs = @mofs.offset(offset).take(ENV['PAGE_SIZE'])
        end
      }
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_mof
    @mof = Mof.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def mof_params
    params.require(:mof).permit(:atoms, :mof, :batch, :mofkey, :mofid, :hashkey, :name, :database, :cif, :void_fraction, :surface_area_m2g, :surface_area_m2cm3, :pld, :lcd, :pxrd, :pore_size_distribution)
  end
end