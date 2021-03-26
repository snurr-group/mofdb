class BatchesController < ApplicationController

  skip_forgery_protection only: [:create, :destroy]
  before_action :verify_access, only: [:create, :destroy]
  before_action :set_batch, only: [:show, :destroy]

  def show
  end

  def index
    @batches = Batch.all
  end

  def destroy
    isotherms = @batch.isotherms.size
    @batch.isotherms.destroy_all
    @batch.destroy
    return render :json => {status: 'success', msg: "Deleted all #{isotherms}"}
  end

  def create
    batch = Batch.create
    return redirect_to "/batches/#{batch.id}"
  end

  private
  def set_batch
    @batch = Batch.find(params[:id])
  end

end
