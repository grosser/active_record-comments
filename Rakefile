require "bundler/setup"
require "bundler/gem_tasks"
require "bump/tasks"
require "wwtd/tasks"
require "appraisal"

task :spec do
  sh "rspec spec/"
end

task :default => ["appraisal:gemfiles", :wwtd]
