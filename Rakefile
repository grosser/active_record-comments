require "bundler/setup"
require "bundler/gem_tasks"
require "bump/tasks"

task :spec do
  sh "rspec spec/"
end

task :default => :spec

desc "Bundle all gemfiles"
task :bundle_all do
  Bundler.with_original_env do
    Dir["gemfiles/*.gemfile"].each do |gemfile|
      sh "BUNDLE_GEMFILE=#{gemfile} bundle"
    end
  end
end
