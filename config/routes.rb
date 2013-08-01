Sports::Application.routes.draw do
  match ':controller/graph(.:format)', :action => :graph

  resources :routes
  resources :tours
  resources :weights

  root :to => 'weights#index'
  match ':controller(/:action(/:id))(.:format)'
  match ':controller/:action/:id.:format'
end
