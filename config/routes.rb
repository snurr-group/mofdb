Rails.application.routes.draw do

  resources :mofs do
    collection do
      get '/bulk' => 'mofs#bulk', as: 'bulk'
      get '/search' => 'mofs#index', as: "search"
      post '/upload' => 'mofs#upload', as: 'upload'
    end
    member do
      get '/cif' => 'mofs#cif', as: "cif"
    end
  end
  resources :isotherms, format: :json do
    collection do
      post '/upload' => 'isotherms#upload', as: "upload"
    end
  end
  root 'mofs#index'
  get '/api' => 'mofs#api', as: 'api'
  get '/databases' => 'mofs#databases', as: 'databases'

end
