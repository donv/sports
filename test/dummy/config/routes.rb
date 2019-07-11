# frozen_string_literal: true

Rails.application.routes.draw do
  puts 'routes mounted'
  mount Sports::Engine => '/sports'
end
