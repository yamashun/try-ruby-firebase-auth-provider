Rails.application.routes.draw do
  resources :users

  get '/authorize', to: 'authorization#authorize'
  post '/approve', to: 'authorization#approve'
  post '/token', to: 'authorization#token'

  get '/test_page', to: 'authorization#test_page'
end
