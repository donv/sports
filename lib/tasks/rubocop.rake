if Rails.env.test?
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new

  task :test do
    Rake::Task['rubocop:auto_correct'].invoke
  end
end
