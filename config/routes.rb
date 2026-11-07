Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  get "up" => "rails/health#show", as: :rails_health_check

  # Public Landing Page
  root "pages#home"

  # Authenticated Dashboard
  get "dashboard", to: "dashboard#index", as: :dashboard

  # Card Management & Builder
  resources :cards do
    member do
      get :download_pdf
      get :download_qr
      get :download_resume
      post :duplicate
      get :preview
    end
  end

  # Smart QR Public Profile & Export Endpoints
  get "c/:slug", to: "public_cards#show", as: :public_card
  get "c/:slug/vcard", to: "public_cards#vcard", as: :public_card_vcard
  get "c/:slug/qr", to: "public_cards#qr", as: :public_card_qr
  get "c/:slug/pdf", to: "public_cards#pdf", as: :public_card_pdf
  get "c/:slug/resume", to: "public_cards#resume", as: :public_card_resume
end
