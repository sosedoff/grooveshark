require 'bundler'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

begin
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new(:rubocop)
rescue LoadError
  puts 'Rubocop is needed to run this task.'
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

task default: [:rubocop, :spec]
