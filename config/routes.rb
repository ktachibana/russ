Rails.application.routes.draw do
  resources :subscriptions, only: %i(show new create update destroy) do
    collection do
      put :update_all
      get :upload
      post :import
    end
  end

  resources :feeds, only: :index
  resources :items, only: :index
  resources :tags, only: :index
  resource :initial, only: :show
  devise_for :users, controllers: { sessions: 'users/sessions' }

  root to: 'root#index'
end
