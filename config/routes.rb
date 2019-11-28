Rails.application.routes.draw do
  root to: 'pages#home'

  devise_for :users, :controllers => { omniauth_callbacks: 'callbacks' }

  devise_scope :user do
    get 'login', to: 'devise/sessions#new'
  end

  devise_scope :user do
    get 'signup', to: 'devise/registrations#new'
  end

  get 'generate', to: 'pages#generate'
  resources :projects, only: [:index, :show, :create, :new] do
    resources :files, only: [:index]
    get 'template', to: 'projects#template'
    get 'template/devise/:devise_model', to: 'projects#devise_template'
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
