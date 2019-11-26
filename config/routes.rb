Rails.application.routes.draw do
  root to: 'pages#home'
  devise_for :users, :controllers => { omniauth_callbacks: 'callbacks' }

  devise_scope :user do
    get 'login', to: 'devise/sessions#new'
  end

  devise_scope :user do
    get 'signup', to: 'devise/registrations#new'
  end

  resources :users, only: [:show] do
    resources :projects, only: [:show]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
