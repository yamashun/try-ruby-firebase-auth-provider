Rails.application.routes.draw do
  resources :users

  get '/authorize', to: 'authorization#authorize'
  get '/approve', to: 'authorization#approve'
  post '/approve', to: 'authorization#approve'
  post '/token', to: 'authorization#token'

  get '/userinfo', to: 'protected_resources#userinfo'
  post '/userinfo', to: 'protected_resources#userinfo'

  get '/.well-known/openid-configuration'

  get '/test_page', to: 'authorization#test_page'
end
