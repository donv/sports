set :application, 'sports'
set :repository, "svn+ssh://capistrano@source.kubosch.no/var/svn/trunk/#{application}"

role :web, 'kubosch.no'
role :app, 'kubosch.no'
role :db, 'kubosch.no', :primary => true

set :user, 'capistrano'
set :use_sudo, false

set :keep_releases, 10
after 'deploy:update', 'deploy:cleanup'

namespace :deploy do
  desc 'The spinner task is used by :cold_deploy to start the application up'
  task :spinner, :roles => :app do
    send(run_method, "/sbin/service #{application} start")
  end

  desc 'Restart the service'
  task :restart, :roles => :app do
    send(run_method, "/sbin/service #{application} restart")
  end
end
