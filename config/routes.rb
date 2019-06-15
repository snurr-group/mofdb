Rails.application.routes.draw do
  resources :isotherms
  resources :mofs
  resources :isotherms, format: :json
  root 'mofs#index'
end
