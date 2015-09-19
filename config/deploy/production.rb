set :application, 'sports'
set :scm, :svn
set :repo_url, "svn+ssh://capistrano@kubosch.no/var/svn/trunk/#{fetch :application}"
set :deploy_to, -> { "/u/apps/#{fetch :application}" }
set :keep_releases, 10

role :app, %w{capistrano@kubosch.no}
role :web, %w{capistrano@kubosch.no}
role :db,  %w{capistrano@kubosch.no}

server 'kubosch.no', user: 'capistrano', roles: %w{web app}, my_property: :my_value


