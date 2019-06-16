Rails.application.routes.draw do

  resources :mofs do
    collection do
      get '/search' => 'mofs#index', as: "search"
    end
  end
  resources :isotherms, format: :json
  root 'mofs#index'

end
