Rails.application.routes.draw do

  root 'mofs#homepage'
  get '/api' => 'mofs#api', as: 'api'
  get '/databases' => 'mofs#databases', as: 'databases'
  resources :mofs do
    collection do
      get '/count' => 'mofs#count', as: "count"
      post '/upload' => 'mofs#upload', as: 'upload'
    end
    member do
      get '/cif' => 'mofs#cif', as: "cif"
    end
  end

  resources :batches, only: [:show, :index, :destroy, :create]
  resources :forcefields, only: [:index, :create, :update, :edit]
  resources :database_files, only: [:create, :destroy, :index]
  resources :classifications, only: [:index]

  resources :isotherms, format: :json do
    collection do
      post '/upload' => 'isotherms#upload', as: "upload"
    end
  end

  post '/setUnits' => 'application#set_units'

end
