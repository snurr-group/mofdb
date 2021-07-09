Rails.application.routes.draw do

  resources :mofs do
    collection do
      get '/search' => 'mofs#index', as: "search"
      get '/count' => 'mofs#index', as: "count"
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
  root 'mofs#index'
  get '/api' => 'mofs#api', as: 'api'
  get '/databases' => 'mofs#databases', as: 'databases'
  post '/setUnits' => 'application#setUnits'

end
