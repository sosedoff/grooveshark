require 'bundler'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop)

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

task default: [:rubocop, :spec]
