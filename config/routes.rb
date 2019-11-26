Rails.application.routes.draw do
  root to: 'pages#home'

  resources :pages, only: [:home, :about]
  devise_for :users
  resources :projects, only: [:index, :show, :create, :new] do
    resources :files, only: [:index]
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
