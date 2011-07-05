# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require 'soywiki'
Gem::Specification.new do |s|
  s.name        = "soywiki"
  s.version     = Soywiki::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Daniel Choi"]
  s.email       = ["dhchoi@gmail.com"]
  s.homepage    = "http://danielchoi.com/software/soywiki.html"
  s.summary     = %q{Wiki with Vim interface and Git repo}
  s.description = %q{A personal and collaborative wiki for Vim users}

  s.rubyforge_project = "soywiki"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  #s.add_dependency 'haml'
  #s.add_dependency 'rdiscount'
end
