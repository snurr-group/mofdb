Rails.application.routes.draw do
  resources :mofs

  root 'mofs#index'
end
