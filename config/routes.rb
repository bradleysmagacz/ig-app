if Rails.env.development?
  require 'sidekiq/web'
end

Rails.application.routes.draw do
  if Rails.env.development?
    mount Sidekiq::Web => '/sidekiq'
  end

  mount ActionCable.server => '/connect'

  devise_for :users, skip: [:sessions, :registrations, :passwords]

  root to: 'welcome#index'
  resource :welcome, only: [] do
    get :pricing 
    get :support
    get :privacy_policy
    get :terms_of_service
  end

  get "/oauth/authorize", to: 'instagram#create'
  post "/oauth/callback", to: "instagram#callback"

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :dashboard, only: [:index]

      namespace :instagram do
        resource :follow, only: [:create, :destroy]
        resource :like, only: [:create, :destroy]
        resource :comment, only: [:create, :destroy]
      end

      devise_scope :user do 
        post '/user', to: 'registrations#create'
        put '/user', to: 'registrations#update'
        delete '/user', to: 'registrations#destroy'
        post '/user/sign_in', to: 'sessions#create'
        delete '/user/sign_out', to: 'sessions#destroy'
        post '/user/password', to: 'passwords#create'
        put '/user/password', to: 'passwords#update'
      end
    end
  end
end
