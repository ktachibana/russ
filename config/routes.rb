Rails.application.routes.draw do
  resources :subscriptions do
    collection do
      put :update_all
      get :upload
      post :import
    end
  end

  resources :feeds
  resources :items
  devise_for :users

  root to: 'root#index'
end
