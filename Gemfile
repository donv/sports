source 'https://rubygems.org'

ruby File.read("#{__dir__}/.ruby-version")[5..-1]

gem 'rails', '~>4.2.4'

platform :jruby do
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'rmagick4j'
  gem 'therubyrhino'
end

platform :ruby do
  gem 'pg'
  gem 'rmagick'
  gem 'therubyracer'
end

gem 'bootstrap-datepicker-rails'
gem 'bootstrap3-datetimepicker-rails'
gem 'bootstrap-sass'
gem 'coffee-rails'
gem 'dynamic_form'
gem 'gruff'
gem 'jquery-rails'
gem 'momentjs-rails'
gem 'sass-rails'
gem 'schema_plus'
gem 'puma'
gem 'uglifier'
gem 'will_paginate'

group :development do
  # gem 'bullet'
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
end

group :test do
  gem 'minitest-reporters'
  gem 'rubocop'
  gem 'simplecov'
end
