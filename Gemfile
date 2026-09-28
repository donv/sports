# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in sports.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]

group :development do
  gem 'bullet'
  gem 'listen'
  gem 'rails-controller-testing'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'simplecov'
  gem 'sqlite3'
end

# Test against the Rails version the host app uses
gem 'rails', '~> 8.0.5'

# json 3 removed options that Rails 8.0 still passes; drop this pin with Rails 8.1.
gem 'json', '< 3'
