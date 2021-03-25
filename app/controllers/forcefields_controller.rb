class ForcefieldsController < ApplicationController

  before_action :verify_access, only: [:create]
  skip_forgery_protection only: [:create, :update]
  before_action :set_ff, only: [:update]

  def index
    render :json => Forcefield.all.map{|f| {name: f.name, id: f.id} }
  end

  def update
    @ff.update(name: params[:name])
    @ff.save!
    render :json => {name: @ff.name, id: @ff.id}, status: 200
  end

  def create
    f = Forcefield.create(name: params[:name])
    if f.nil?
      render :json => {status: 'failure', msg: 'be sure to supply a name parameter' }, status: 500
    else
      render :json => {status: 'success', name: f.name, id: f.id}, status: 200
    end
  end

  private

  def set_ff
    @ff = Forcefield.find(params[:id])
  end

  def ff_params
    puts params
    params.require(:id)
  end

end
