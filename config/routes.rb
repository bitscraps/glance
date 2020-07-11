Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :dashboard, only: :index
  resource :whats_playing, only: [:show, :update]
  resources :calendar_events, only: :index
end
