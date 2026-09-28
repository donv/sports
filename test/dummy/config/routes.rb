# frozen_string_literal: true

Rails.application.routes.draw do
  mount Sports::Engine => '/sports'

  get 'account/login', to: 'account#login'
  post 'account/test_login', to: 'account#test_login'
end
