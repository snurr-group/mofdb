Rails.application.routes.draw do

  root 'mofs#homepage'
  get '/api' => 'mofs#api', as: 'api'
  resources :mofs do
    collection do
      get '/count' => 'mofs#count', as: "count"
      post '/upload' => 'mofs#upload', as: 'upload'
    end
    member do
      get '/cif' => 'mofs#cif', as: "cif"
    end
  end
  resources :databases, only: [:index, :create, :destroy]
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
  get '/down' => 'down#index'

end
