Rails.application.routes.draw do
  get 'counters/new'
  root to: 'sessions#top'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  resources :members, :catalogs, :stocks
  resources :loans do
    collection do
      # post :confirm
      get :confirm
    end
  end
end
