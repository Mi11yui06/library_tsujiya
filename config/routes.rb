Rails.application.routes.draw do
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
  resources :counters do
    collection do
      get :confirm_return
      get :confirm_loan
    end
  end
end