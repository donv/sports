set :application, "sports"
set :repository, "svn+ssh://donv@source.kubosch.no/var/svn/trunk/#{application}"

role :app, "www.kubosch.no"
role :db,  "www.kubosch.no", :primary => true

set :user, "donv"
use_sudo = false

desc "The spinner task is used by :cold_deploy to start the application up"
task :spinner, :roles => :app do
  send(run_method, "/sbin/service #{application} start")
end

desc "Restart the mongrel server"
task :restart, :roles => :app do
  send(run_method, "/sbin/service #{application} restart")
end
