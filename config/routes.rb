# config/routes.rb
Rails.application.routes.draw do
  root "welcome#index"

  get "welcome/index", to: "welcome#index", as: "welcome"
  get "welcome/guest", as: "guest"

  get "sessions/logout", to: "sessions#logout", as: "logout"
  get "sessions/omniauth", to: "sessions#omniauth"

  get "/auth/google_oauth2/callback", to: "sessions#omniauth"
  get "/auth/github/callback", to: "sessions#github"
  get "/auth/spotify/callback", to: "sessions#spotify"

  resources :users

  resources :games, param: :id
  get "spellingbee/:id", to: "games#spellingbee", as: "spellingbee"
  post "spellingbee/:id", to: "games#spellingbee"
  get "/wordles/play", to: "wordles#play", as: "wordles_play"
  resources :wordles
  get "/letterboxed/:id", to: "games#demo_game", as: "letterboxed"

  post "settings/update"

  get "up", to: "rails/health#show", as: :rails_health_check

  resources :aesthetics, param: :game_id

  get "dashboard", to: "dashboard#show", as: "dashboard"
  # resources :users do # nested routes for roles for all users
  #   collection do
  #     post :update_roles
  #   end
  # end

  resources :roles do
    post :update_roles, on: :collection
  end

  resources :settings, only: [ :update ] # Update settings for the current user

  # auto generated rails controller based routes
  resources :games
  resources :users
  resources :wordles do
    collection do
      post "submit_guess"
      get "play"
    end
  end
end
