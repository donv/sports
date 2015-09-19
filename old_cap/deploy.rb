set :application, 'sports'
set :repository, "svn+ssh://capistrano@source.kubosch.no/var/svn/trunk/#{application}"

role :web, 'kubosch.no'
role :app, 'kubosch.no'
role :db, 'kubosch.no', primary: true

set :user, 'capistrano'

set :keep_releases, 10
after 'deploy:update', 'deploy:cleanup'

namespace :deploy do
  desc 'The spinner task is used by :cold_deploy to start the application up'
  task :spinner, roles: :app do
    run "#{try_sudo} /usr/bin/systemctl start #{application}"
  end

  desc 'Restart the service'
  task :restart, roles: :app do
    run "#{try_sudo} /usr/bin/systemctl restart #{application}"
  end
end