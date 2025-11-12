Rails.application.routes.draw do
  # Porta de entrada do convite (apenas new/create)
  resource :signup_gate, only: [:new, :create], controller: "signup_gate"

  # Devise usando o controller custom de registrations (uma única linha!)
  devise_for :users, controllers: { registrations: "users/registrations" }

  # Seus recursos
  resources :entries

  # config/routes.rb
  resources :temporary_passwords, only: [:create]

  # Healthcheck
  get "up" => "rails/health#show", as: :rails_health_check

  # Root
  root "entries#index"
end
