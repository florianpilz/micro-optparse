require 'bundler'
require 'rspec/core/rake_task'

include Rake::DSL

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new(:spec)
task :default => :spec
