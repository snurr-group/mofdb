require 'zip'

class MofsController < ApplicationController
  before_action :set_mof, only: [:show, :edit, :update, :destroy, :cif]
  skip_forgery_protection only: [:upload]
  before_action :verify_access, only: [:upload]

  # GET /mofs
  # GET /mofs.json
  def index

    # In this if block we change how we load the Mof.all object depending on the query
    # 0. Filtering by gases requires a couple joins we do this up here before we apply the simple where filters. Explanation below.
    # 1. if we are sorting by gases we start with the gases and load the mofs via has_many
    # 2. If we are loading html (<tr></tr>) rows that get inserted into the homepage table we need to include the database/elements so we preload them
    # 3. Preload database for homepage via
    # 4. Preload nothing for json since we will just the pregen_json column on the mofs.

    if params[:gases]
      gas_ids = params[:gases].map {|gas_name| Gas.find_gas(gas_name).id}.uniq
      # 0.
      # We join mofs to isotherms then isotherms to isodata and then filter isodata by gas
      @mofs = Mof.joins("INNER JOIN isotherms on isotherms.mof_id = mofs.id").joins("INNER JOIN isodata on isodata.isotherm_id = isotherms.id").where("isodata.gas_id in (?)", gas_ids).distinct
    else
      if params[:html] or params[:cifs] # 2.
        @mofs = Mof.all.includes(:database, :elements)
      else
        respond_to do |format|
          # 3.
          format.html {@mofs = Mof.all.includes(:database)}
          # 4.
          format.json {@mofs = Mof.all}
        end
      end
    end


    begin
      filter_mofs
    rescue PageTooLarge
      return render :json => {"error": "Page number too large"}, status: 400
    end

    if params[:html]
      render partial: 'mofs/rows'
      return
    end

    # If params[:cifs] is set it means we're going to serve a zip file instead of an HTML page
    # we exclude all CSD mofs since those cifs are prviate.
    if params[:cifs] && params[:cifs] == "true" && @mofs.any?
      csd = Database.find_by(name: "CSD")
      @mofs = @mofs.select {|mof| mof.database != csd}
      temp_name = "mof-dl-#{SecureRandom.hex(8)}.zip"
      temp_path = Rails.root.join(Rails.root.join("tmp"), temp_name)

      Zip::OutputStream.open(temp_path) do |io|
        @mofs.each do |mof|
          io.put_next_entry(mof.name + ".cif")
          io.write(mof.cif)
        end
      end

      File.open(temp_path, 'r') do |file|
        send_data file.read, :type => 'application/zip', :filename => temp_name
      end
      File.delete(temp_path)
      return
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
    @mof = Mof.find_by(hashkey: hashkey)

    begin
      elements = JSON.parse(params[:atoms]).map {|atm| Element.find_by(symbol: atm == "x" ? "Xe" : atm)}
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
                  pore_size_distribution: params[:pore_size_distribution]}

    if params[:db] == "hMOFs"
      mof_params[:database] = Database.find_by(name: "hMOF")
    else
      mof_params[:database] = Database.find_by(name: params[:db])
    end


    if @mof.nil?
      puts "Elements is:"
      puts mof_params[:elements]
      @mof = Mof.new(mof_params)
      @mof.save!
    else
      @mof.update(mof_params)
    end
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
  end


  private

  def filter_mofs
    ## VOID FRAC
    if params[:vf_min] && !params[:vf_min].empty? && params[:vf_min] && params[:vf_min].to_f != 0
      @mofs = @mofs.where("void_fraction >= ?", params[:vf_min])
    end

    if params[:vf_max] && !params[:vf_max].empty? && params[:vf_max].to_f != 1
      @mofs = @mofs.where("void_fraction <= ?", params[:vf_max])
    end

    ### PLD
    if params[:pld_min] && !params[:pld_min].empty? && params[:pld_min].to_f != 0
      @mofs = @mofs.where("pld >= ?", params[:pld_min])
    end


    if params[:pld_max] && !params[:pld_max].empty? && params[:pld_max].to_f != 20
      @mofs = @mofs.where("pld <= ?", params[:pld_max])
    end

    ### LCD
    if params[:lcd_min] && !params[:lcd_min].empty? && params[:lcd_min].to_f != 0
      @mofs = @mofs.where("lcd >= ?", params[:lcd_min])
    end

    if params[:lcd_max] && !params[:lcd_max].empty? && params[:lcd_max].to_f != 100
      @mofs = @mofs.where("lcd <= ?", params[:lcd_max])
    end

    ### SA M2G
    if params[:sa_m2g_min] && !params[:sa_m2g_min].empty? && params[:sa_m2g_min].to_f != 0
      @mofs = @mofs.where("surface_area_m2g >= ?", params[:sa_m2g_min])
    end

    if params[:sa_m2g_max] && !params[:sa_m2g_max].empty? && params[:sa_m2g_max].to_f != 5000
      @mofs = @mofs.where("surface_area_m2g <= ?", params[:sa_m2g_max])
    end

    ### SA M2G
    if params[:sa_m2cm3_min] && !params[:sa_m2cm3_min].empty? && params[:sa_m2cm3_min].to_f != 0
      @mofs = @mofs.where("surface_area_m2cm3 >= ?", params[:sa_m2cm3_min])
    end

    if params[:sa_m2cm3_max] && !params[:sa_m2cm3_max].empty? && params[:sa_m2cm3_max].to_f != 5000
      @mofs = @mofs.where("surface_area_m2cm3 <= ?", params[:sa_m2cm3_max])
    end

    # NAME
    if params[:name] && !params[:name].empty?
      @mofs = @mofs.where("name LIKE ?", "%" + params[:name] + "%")
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

    # if params[:gases] && !params[:gases].empty?
    #   @mofs = @mofs.select {|mf| (mf.gases.pluck(:name) & params[:gases]).any?}
    # end

    if params[:doi] && !params[:doi].empty?
      puts "finding dois..."
      @mofs = Isotherm.where(doi: params[:doi]).limit(500)
      puts "mapping to mofs..."
      @mofs = @mofs.map {|iso| iso.mof}
      puts "flattening ..."
      @mofs = @mofs.flatten
      puts "unique only ..."
      @mofs = @mofs.uniq
    end


    respond_to do |format|
      format.html {
        @mofs = @mofs.take(100)
      }
      format.json {
        page = params['page'].to_i # nil -> 0
        page = 1 if page == 0
        offset = (ENV['PAGE_SIZE'].to_i) * (page - 1)
        raise PageTooLarge if offset > @mofs.size
        @mofs = @mofs.offset(offset).take(ENV['PAGE_SIZE'])
      }
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_mof
    @mof = Mof.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def mof_params
    params.require(:mof).permit(:hashkey, :name, :db, :cif, :void_fraction, :surface_area_m2g, :surface_area_m2cm3, :pld, :lcd, :pxrd, :pore_size_distribution)
  end
end