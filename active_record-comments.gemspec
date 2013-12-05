name = "active_record-comments"

Gem::Specification.new name, "0.1.2" do |s|
  s.summary = "Comments for activerecord"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "https://github.com/grosser/#{name}"
  s.files = `git ls-files lib/ MIT-LICENSE`.split("\n")
  s.license = "MIT"

  cert = File.expand_path("~/.ssh/gem-private-key-AUTHOR_GITHUB.pem")
  if File.exist?(cert)
    s.signing_key = cert
    s.cert_chain = ["gem-public_cert.pem"]
  end

  s.add_runtime_dependency "activerecord"
end
