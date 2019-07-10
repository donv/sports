require 'momentjs-rails'
require 'bootstrap-datepicker-rails'
require 'bootstrap3-datetimepicker-rails'
require 'slim-rails'
require 'bootstrap-sass'
require 'jquery-rails'

module Sports
  class Engine < ::Rails::Engine
    isolate_namespace Sports
  end
end
