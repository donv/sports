$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'sports/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'sports'
  spec.version     = Sports::VERSION
  spec.authors     = ['Uwe Kubosch']
  spec.email       = ['uwe@datek.no']
  spec.homepage    = 'https://github.com/donv/sports'
  spec.summary     = 'Personal sports stats tracking'
  spec.description = 'Personal sports stats tracking'
  # spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'bootsnap'
  spec.add_dependency 'bootstrap-datepicker-rails'
  spec.add_dependency 'bootstrap-sass'
  spec.add_dependency 'bootstrap3-datetimepicker-rails'
  spec.add_dependency 'coffee-rails'
  spec.add_dependency 'dynamic_form'
  spec.add_dependency 'gruff'
  spec.add_dependency 'jquery-rails'
  spec.add_dependency 'mini_racer'
  spec.add_dependency 'momentjs-rails'
  spec.add_dependency 'pg'
  spec.add_dependency 'puma'
  spec.add_dependency 'rails', '~> 5.2'
  spec.add_dependency 'rmagick'
  spec.add_dependency 'sass-rails'
  spec.add_dependency 'slim-rails'
  spec.add_dependency 'uglifier'
  spec.add_dependency 'will_paginate'

  spec.add_development_dependency 'bullet'
  spec.add_development_dependency 'listen'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'rails-controller-testing'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'sqlite3'
end
