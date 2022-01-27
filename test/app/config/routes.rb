Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get '/records', to: 'records#index'

  post '/records', to: 'records#create'
  post '/records/:id/add_attachment', to: 'records#add_attachment'
end
