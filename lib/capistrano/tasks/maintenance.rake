# frozen_string_literal: true

desc 'Announce maintenance'
task :announce_maintenance do
  on roles :all do
    within("#{current_path}/public") { execute :cp, '503_update.html 503.html' }
  end
end
before 'deploy:starting', :announce_maintenance

desc 'Announce maintenance in the release area'
task :announce_maintenance_release do
  on roles :all do
    within("#{release_path}/public") { execute :cp, '503_update.html 503.html' }
  end
end
after 'deploy:updated', :announce_maintenance_release

desc 'End maintenance'
task :end_maintenance do
  on roles :all do
    within("#{current_path}/public") { execute :cp, '503_down.html 503.html' }
  end
end
after 'deploy:finished', :end_maintenance
