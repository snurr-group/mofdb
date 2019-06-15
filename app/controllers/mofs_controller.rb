class MofsController < ApplicationController
  before_action :set_mof, only: [:show, :edit, :update, :destroy]

  # GET /mofs
  # GET /mofs.json
  def index
    @mofs = Mof.all

    ## VOID FRAC
    if params[:vf_min]
      @mofs = @mofs.where("void_fraction > ?",params[:vf_min])
    end

    if params[:vf_max]
      @mofs = @mofs.where("void_fraction < ?",params[:vf_max])
    end

    ### PLD
    if params[:pld_min]
      @mofs = @mofs.where("pld> ?",params[:pld_min])
    end


    if params[:pld_max]
      @mofs = @mofs.where("pld< ?",params[:pld_max])
    end

    ### LCD
    if params[:lcd_min]
      @mofs = @mofs.where("lcd > ?",params[:lcd_min])
    end

    if params[:lcd_min]
      @mofs = @mofs.where("lcd < ?",params[:lcd_max])
    end

    ### SA M2G
    if params[:sa_m2g_min]
      @mofs = @mofs.where("surface_area_m2g > ?",params[:sa_m2g_min])
    end

    if params[:sa_m2g_max]
      @mofs = @mofs.where("surface_area_m2g < ?",params[:sa_m2g_max])
    end

    ### SA M2G
    if params[:sa_m2cm3_min]
      @mofs = @mofs.where("surface_area_m2cm3 > ?",params[:sa_m2cm3_min])
    end

    if params[:sa_m2cm3_max]
      @mofs = @mofs.where("surface_area_m2cm3 < ?",params[:sa_m2cm3_max])
    end

    if params[:name]
      @mofs = @mofs.where("name LIKE ?", "%"+params[:name]+"%")
    end

    if params[:database] && params[:database] != "Any"
      database = Database.find_by(name: params[:database])
      @mofs = @mofs.where(database: database)
    end

    if params[:limit]
      @mofs = @mofs.take(params[:limit])
    end

    if params[:n2] == "true"
      @mofs = @mofs.select { |mf| mf.gases.pluck(:name).include?("Ammonia")}
    end

    # N2
    # X2
    # Kr
    # H2
    # CO2
    # CH4
    # H2O
    # db_choice
    # elements
    # doi


  end

  # GET /mofs/1
  # GET /mofs/1.json
  def show
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mof
      @mof = Mof.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mof_params
      params.require(:mof).permit(:hashkey, :name, :db, :cif, :void_fraction, :surface_area_m2g, :surface_area_m2cm3, :pld, :lcd, :pxrd, :pore_size_distribution)
    end
end
