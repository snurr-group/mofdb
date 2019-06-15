class MofsController < ApplicationController
  before_action :set_mof, only: [:show, :edit, :update, :destroy]

  # GET /mofs
  # GET /mofs.json
  def index
    @mofs = Mof.all
  end

  # GET /mofs/1
  # GET /mofs/1.json
  def show
  end

  # GET /mofs/new
  def new
    @mof = Mof.new
  end

  # GET /mofs/1/edit
  def edit
  end

  # POST /mofs
  # POST /mofs.json
  def create
    @mof = Mof.new(mof_params)

    respond_to do |format|
      if @mof.save
        format.html { redirect_to @mof, notice: 'Mof was successfully created.' }
        format.json { render :show, status: :created, location: @mof }
      else
        format.html { render :new }
        format.json { render json: @mof.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mofs/1
  # PATCH/PUT /mofs/1.json
  def update
    respond_to do |format|
      if @mof.update(mof_params)
        format.html { redirect_to @mof, notice: 'Mof was successfully updated.' }
        format.json { render :show, status: :ok, location: @mof }
      else
        format.html { render :edit }
        format.json { render json: @mof.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mofs/1
  # DELETE /mofs/1.json
  def destroy
    @mof.destroy
    respond_to do |format|
      format.html { redirect_to mofs_url, notice: 'Mof was successfully destroyed.' }
      format.json { head :no_content }
    end
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
