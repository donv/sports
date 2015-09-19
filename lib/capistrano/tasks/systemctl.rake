namespace :deploy do
  desc 'The spinner task is used by :cold_deploy to start the application up'
  task :spinner do
    on roles :all do
      execute :sudo, "systemctl start #{fetch :application}"
    end
  end

  desc 'Restart the service'
  task :restart do
    on roles :all do
      execute :sudo, "systemctl restart #{fetch :application}"
    end
  end

  task :symlinks do
    on roles :all do
      execute :sudo, <<-SCRIPT
        echo "Updating init script"
        rm -f /usr/lib/systemd/system/#{fetch :application}.service
        sudo cp -a #{current_path}/usr/lib/systemd/system/#{fetch :application}.service /usr/lib/systemd/system/#{fetch :application}.service
      SCRIPT
    end
  end

  task :reload_daemons do
    on roles :all do
      execute :sudo, 'systemctl daemon-reload'
    end
  end
end

before 'deploy:restart', 'deploy:reload_daemons'
