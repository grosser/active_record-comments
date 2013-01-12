$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
name = "active_record-comments"
require name.sub("-","/")

Gem::Specification.new name, ActiveRecord::Comments::VERSION do |s|
  s.summary = "Comments for activerecord"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "http://github.com/grosser/#{name}"
  s.files = `git ls-files`.split("\n")
  s.license = "MIT"
  s.add_runtime_dependency "activerecord"
end
