Rails.application.routes.draw do
  resources :users

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'

  get '/authorize', to: 'authorization#authorize'
  post '/token', to: 'authorization#token'
end
