class MofsController < ApplicationController
  before_action :set_mof, only: [:show, :edit, :update, :destroy]

  # GET /mofs
  # GET /mofs.json
  def index
    @mofs = Mof.all

    ## VOID FRAC
    if params[:vf_min] && !params[:vf_min].empty?
      @mofs = @mofs.where("void_fraction > ?",params[:vf_min])
    end

    if params[:vf_max] && !params[:vf_max].empty?
      @mofs = @mofs.where("void_fraction < ?",params[:vf_max])
    end

    ### PLD
    if params[:pld_min] && !params[:pld_min].empty?
      @mofs = @mofs.where("pld> ?",params[:pld_min])
    end


    if params[:pld_max] && !params[:pld_max].empty?
      @mofs = @mofs.where("pld< ?",params[:pld_max])
    end

    ### LCD
    if params[:lcd_min] && !params[:lcd_min].empty?
      @mofs = @mofs.where("lcd > ?",params[:lcd_min])
    end

    if params[:lcd_min] && !params[:lcd_min].empty?
      @mofs = @mofs.where("lcd < ?",params[:lcd_max])
    end

    ### SA M2G
    if params[:sa_m2g_min] && !params[:sa_m2g_min].empty?
      @mofs = @mofs.where("surface_area_m2g > ?",params[:sa_m2g_min])
    end

    if params[:sa_m2g_max] && !params[:sa_m2g_max].empty?
      @mofs = @mofs.where("surface_area_m2g < ?",params[:sa_m2g_max])
    end

    ### SA M2G
    if params[:sa_m2cm3_min] && !params[:sa_m2cm3_min].empty?
      @mofs = @mofs.where("surface_area_m2cm3 > ?",params[:sa_m2cm3_min])
    end

    if params[:sa_m2cm3_max] && !params[:sa_m2cm3_max].empty?
      @mofs = @mofs.where("surface_area_m2cm3 < ?",params[:sa_m2cm3_max])
    end

    if params[:name] && !params[:name].empty?
      @mofs = @mofs.where("name LIKE ?", "%"+params[:name]+"%")
    end

    if params[:database] && params[:database] != "Any" && !params[:database].empty?
      database = Database.find_by(name: params[:database])
      @mofs = @mofs.where(database: database)
    end

    if params[:limit] && !params[:limit].empty?
      @mofs = @mofs.take(params[:limit])
    end

    if params[:gases] && !params[:gases].empty?
      @mofs = @mofs.select { |mf| (mf.gases.pluck(:name) & params[:gases]).any? }
    end

    if params[:doi] && !params[:doi].empty?
      @mofs = @mofs.select { | mf| mf.isotherms.pluck(:doi).include?(params[:doi]) }
    end

    if params[:html]
      render partial: 'mofs/rows'
      return
    end

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
