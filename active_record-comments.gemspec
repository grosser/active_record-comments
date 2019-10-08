name = "active_record-comments"

Gem::Specification.new name, "0.1.3" do |s|
  s.summary = "Comments for activerecord"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "https://github.com/grosser/#{name}"
  s.files = `git ls-files lib/ MIT-LICENSE`.split("\n")
  s.license = "MIT"
  s.add_runtime_dependency "activerecord", ">= 4", "< 7"
  s.required_ruby_version = '>= 2.4'
end
