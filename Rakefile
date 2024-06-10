require "bundler/setup"
require "bundler/gem_tasks"
require "bump/tasks"

# update all versions so bundling does not fail on CI
gemfiles = Dir["gemfiles/*.gemfile"] - ["gemfiles/activerecord_main.gemfile"]
Bump.replace_in_default = gemfiles.map { |g| g + ".lock" }

task :spec do
  sh "rspec spec/"
end

task default: :spec

desc "Bundle all gemfiles"
task :bundle_all do
  Bundler.with_original_env do
    gemfiles.each do |gemfile|
      sh "BUNDLE_GEMFILE=#{gemfile} bundle"
    end
  end
end
