require 'rspec/core/rake_task'
require "bundler/gem_tasks"

# Default directory to look in is `/specs`
# Run with `rake spec`
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = ['--color', '--format', 'documentation', '--format', 'Nc']
end

task :console do
  exec "irb -r organizer -I ./lib"
end

task default: :spec
