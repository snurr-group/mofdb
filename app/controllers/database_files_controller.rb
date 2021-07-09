class DatabaseFilesController < ApplicationController
  before_action :verify_access, only: [:create, :destroy]
  skip_forgery_protection only: [:create, :destroy]
  before_action :set_zip, only: [:destroy]


  def index
    render json: DatabaseFile.all.map{|zip| {name: zip.name,
                                             id: zip.id,
                                             path: url_for(zip.file),
                                             category: zip.category}}
  end

  def create
    unless DatabaseFile.find_by(name: params[:name]).nil?
      return render json: { error: "There is already a file with the name #{params[:name]}"}, status: 500
    end
    begin
      zip = DatabaseFile.create!({ name: params[:name], category: params[:category]})
      zip.file.attach(params[:file])
      zip.save!
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
    @ffzip = DatabaseFile.find(params[:id])
  end
end