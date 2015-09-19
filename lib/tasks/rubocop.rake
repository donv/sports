require 'rubocop/rake_task'
RuboCop::RakeTask.new

task :test do
  Rake::Task[:rubocop].invoke
end
