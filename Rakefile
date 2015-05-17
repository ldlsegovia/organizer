require "rspec/core/rake_task"
require "bundler/gem_tasks"
require "yard"

# Default directory to look in is `/specs`
# Run with `rake spec`
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = ['--color', '--format', 'documentation', '--format', 'Nc']
end

YARD::Rake::YardocTask.new do |task|
  task.files   = ['lib/**/*.rb']
end

task :console do
  exec "irb -r organizer -I ./lib"
end

task default: :spec
