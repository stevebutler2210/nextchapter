Rails.application.routes.draw do
  # Auth
  resource :session
  resource :registration, only: %i[new create]
  resources :passwords, param: :token

  # Core app
  root "clubs#index"

  resources :clubs, only: %i[index show new create edit update destroy]
  get "/invites/:signed_id", to: "invites#show", as: :invite

  resources :books, only: [] do
    collection do
      get :search
    end
  end

  # Infrastructure
  get "up" => "rails/health#show", as: :rails_health_check
end
