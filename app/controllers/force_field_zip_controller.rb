class ForceFieldZipController < ApplicationController
  before_action :verify_access, only: [:create, :destroy]
  skip_forgery_protection only: [:create, :destroy]
  before_action :set_zip, only: [:destroy]


  def index
    render json: ForceFieldZip.all.map{|zip| {name: zip.name, id: zip.id, path: url_for(zip.file)}}
  end

  def create
    begin
      zip = ForceFieldZip.create!({ name: params[:name] })
      zip.file.attach(params[:file])
      zip.save
    rescue
      return render json: { error: "Something went wrong upload your zip." }
    end
    render json: { name: zip.name, id: zip.id }
  end

  def destroy
    @ffzip.destroy!
    render json: {msg: "Deleted!"}
  end

  private

  def set_zip
    @ffzip = ForceFieldZip.find(params[:id])
  end
end