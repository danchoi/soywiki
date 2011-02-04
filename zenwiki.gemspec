# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "zenwiki/version"

Gem::Specification.new do |s|
  s.name        = "zenwiki"
  s.version     = Zenwiki::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Daniel Choi"]
  s.email       = ["dhchoi@gmail.com"]
  s.homepage    = "http://danielchoi.com/software/zenwiki.html"
  s.summary     = %q{Couchdb-based wiki with Vim interface}
  s.description = %q{A personal and collaborative wiki}

  s.rubyforge_project = "zenwiki"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'couchrest'
end
