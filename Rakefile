require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError => e
  puts e
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop)
rescue LoadError => e
  puts e
end

begin
  require 'ci/reporter/rake/rspec'
rescue LoadError => e
  puts e
end

task default: [:spec, :rubocop]
