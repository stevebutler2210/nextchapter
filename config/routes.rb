Rails.application.routes.draw do
  # Auth
  resource :session
  resource :registration, only: %i[new create]
  resources :passwords, param: :token

  # Core app
  root "home#index"

  get "/invites/:signed_id", to: "invites#show", as: :invite

  resources :books, only: [] do
    collection do
      get :search
    end
  end

  resources :clubs, only: %i[index show new create edit update destroy] do
    resources :cycles, shallow: true do
      member do
        patch :close_voting
        patch :close_nominations
        post :complete
      end

      resources :nominations, only: [ :create ], shallow: true do
        resources :votes, only: [ :create, :destroy ]
      end

      resources :reading_log_entries, only: [ :create ], shallow: true
    end
  end

  # Infrastructure
  get "up" => "rails/health#show", as: :rails_health_check
end
