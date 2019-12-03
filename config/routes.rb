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
  resources :projects, only: [:index, :show, :create, :new, :destroy, :update] do
    resources :files, only: [:index]
    get 'template', to: 'projects#template'
    get 'template/:all_params', to: 'projects#template_params'
  end

  get 'about', to: 'pages#about'

end
