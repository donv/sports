require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/app/views/'
end

ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

MiniTest::Reporters.use!

class ActiveSupport::TestCase
  fixtures :all
end
