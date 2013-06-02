Russ::Application.routes.draw do
  resources 'rss_sources'
  devise_for :users

  root to: 'root#index'
end
