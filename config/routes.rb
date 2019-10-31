# frozen_string_literal: true

Sports::Engine.routes.draw do
  # resources :routes
  resources :tours, only: :index do
    collection do
      get :graph
      get :graph_small
    end
  end
  resources :weights do
    collection do
      get :graph
      get :graph_small
    end
  end

  root to: 'weights#index'
end
