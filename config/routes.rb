Rails.application.routes.draw do
  get ':controller/graph(.:format)', action: :graph

  resources :routes
  resources :tours
  resources :weights

  root to: 'weights#index'

  get ':controller(/:action(/:id))(.:format)'
  get ':controller/:action/:id.:format'
end
