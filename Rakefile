require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError => e
  puts e
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError => e
  puts e
end
