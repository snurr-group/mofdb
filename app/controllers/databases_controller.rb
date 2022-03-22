include ApplicationHelper

class DatabasesController < ApplicationController
  before_action :verify_access, only: [:create, :destroy]
  skip_forgery_protection only: [:create, :destroy]

  def create
    name = params[:name]
    puts params.inspect
    if !name.nil? && name.is_a?(String) && name.length > 0
      db = Database.create(name: name)
      db.save!
      render :json => {status: RESULTS[:success]}, status: 200
    else
      render :json => {status: RESULTS[:error], error: "Database name should be a non empty string"}.to_json, status: 400
    end
  end

  def destroy
    @db = Database.find(params[:id])
    if @db.mofs.count == 0
      @db.destroy!
      render json: {status: RESULTS[:success], message: "Deleted!"}.to_json, status: 200
    else
      render json: {status: RESULTS[:error], error: "Database has more than 0 mofs (#{@db.mofs.count}! This is a bug in the mofdb-interface"}.to_json, status: 500
    end

  end


  # GET /databases
  def index
    if request.format.symbol == :json
      @dbs = Database.all
    else

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
  end
end