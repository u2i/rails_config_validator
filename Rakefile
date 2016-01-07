require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError => e
  STDERR.puts e
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop)
rescue LoadError => e
  STDERR.puts e
end

begin
  require 'ci/reporter/rake/rspec'
rescue LoadError => e
  STDERR.puts e
end

begin
  require 'u2i/ci_utils/rake_tasks/all'
rescue LoadError => e
  STDERR.puts e
end

task default: [:spec, :rubocop]
