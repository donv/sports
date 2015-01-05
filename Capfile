load 'deploy'
load 'deploy/assets'

set :default_environment, {'JRUBY_OPTS' => '--dev'}
# set :migrate_env, 'JRUBY_OPTS="--dev -J-Xmx3G"'
default_run_options[:pty] = true

require 'rubygems'
require 'bundler/capistrano'
require 'rvm/capistrano'
load 'config/deploy'

desc 'Announce maintenance'
task :announce_maintenance, roles: [:app] do
  run "cd #{current_path}/public ; cp 503_update.html 503.html"
end

desc 'End maintenance'
task :end_maintenance, roles: [:app] do
  run "cd #{current_path}/public ; cp 503_down.html 503.html"
end

before 'deploy:create_symlink', :announce_maintenance
after 'deploy:create_symlink', :announce_maintenance
after 'deploy', :end_maintenance

set :rvm_ruby_string, :ruby
set :rvm_autolibs_flag, 'read-only'

namespace :rvm do
  task :trust_keys, roles: [:app] do
    run 'gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3',
        shell: :bash
  end
end

before 'rvm:install_rvm', 'rvm:trust_keys'
before 'deploy:setup', 'rvm:install_rvm' # install/update RVM
before 'deploy:setup', 'rvm:install_ruby' # install Ruby and create gemset
before 'deploy:spinner', 'deploy:reload_daemons'
before 'deploy:restart', 'deploy:reload_daemons'

namespace :deploy do
  task :symlinks do
    run "#{try_sudo} rm -f /usr/lib/systemd/system/#{application}.service ; #{try_sudo} ln -s /u/apps/#{application}/current/usr/lib/systemd/system/#{application}.service /usr/lib/systemd/system/#{application}.service"
  end

  task :reload_daemons do
    run "#{try_sudo} systemctl daemon-reload"
  end
end
