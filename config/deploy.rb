set :user, 'capistrano'
set :default_environment, {'JRUBY_OPTS' => '--dev'}
# set :migrate_env, 'JRUBY_OPTS="--dev -J-Xmx3G"'
# default_run_options[:pty] = true
set :rvm_ruby_version, File.read(File.expand_path('../.ruby-version', File.dirname(__FILE__))).strip

# after 'deploy:updating', 'deploy:cleanup'

