IcuWwwApp::Application.routes.draw do
  root to: "pages#home"

  get "home"     => "pages#home"
  get "sign_in"  => "sessions#new"
  get "sign_out" => "sessions#destroy"

  resources :sessions, only: [:create]
  
  namespace :admin do
    resources :users,  only: [:index, :show, :edit, :update, :destroy]
    resources :logins, only: [:index, :show]
  end

  match "*url", to: "pages#not_found", via: :all
end
