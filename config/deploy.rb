set :user, 'capistrano'
set :default_environment, {'JRUBY_OPTS' => '--dev'}
set :rvm_ruby_version, File.read(File.expand_path('../.ruby-version', File.dirname(__FILE__))).strip
set :pty, true

after 'deploy:updating', 'deploy:cleanup'
after 'deploy:publishing', 'deploy:restart'
