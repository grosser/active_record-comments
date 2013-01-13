name = "active_record-comments"

Gem::Specification.new name, "0.0.1" do |s|
  s.summary = "Comments for activerecord"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "http://github.com/grosser/#{name}"
  s.files = `git ls-files`.split("\n")
  s.license = "MIT"
  s.add_runtime_dependency "activerecord"
end
