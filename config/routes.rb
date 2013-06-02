Russ::Application.routes.draw do
  resources :feeds do
    collection do
      put :update_all
      get :upload
      post :import
    end
  end

  devise_for :users

  root to: 'root#index'
end
