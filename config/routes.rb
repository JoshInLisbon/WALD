Rails.application.routes.draw do
  root to: 'pages#home'

  devise_for :users, :controllers => { omniauth_callbacks: 'callbacks' }

  devise_scope :user do
    get 'login', to: 'devise/sessions#new'
  end

  devise_scope :user do
    get 'signup', to: 'devise/registrations#new'
  end

  resources :pages, only: [:home, :about]
  resources :projects, only: [:index, :show, :create, :new] do
    resources :files, only: [:index]
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
