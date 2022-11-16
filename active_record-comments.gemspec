require_relative 'lib/active_record/comments/version'

Gem::Specification.new do |s|
  s.name = "active_record-comments"
  s.version = ActiveRecord::Comments::VERSION
  s.summary = "Comments for activerecord"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "https://github.com/grosser/active_record-comments"
  s.files = `git ls-files lib/ MIT-LICENSE`.split("\n")
  s.license = "MIT"
  s.add_runtime_dependency "activerecord", ">= 5", "< 7.1"
  s.required_ruby_version = '>= 2.7'
end
