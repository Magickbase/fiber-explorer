require "sidekiq/web"
require "sidekiq-scheduler/web"

Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use ActionDispatch::Session::CookieStore

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  mount Sidekiq::Web => "/sidekiq"

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :stripe do
    resources :checkout_sessions, param: :session_uid, only: %i[index create destroy]
    resource :subscription, only: %i[show update destroy]
    resources :products, only: :index
    resources :webhooks do
      post :callback, on: :collection
    end
  end
  resources :api_calls, only: %i[index create]
  resources :api_usage, only: :show
  resource :user_info, only: :show
end
