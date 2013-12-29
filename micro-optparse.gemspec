# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "micro-optparse/version"

Gem::Specification.new do |s|
  s.name        = "micro-optparse"
  s.version     = Micro::Optparse::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Florian Pilz"]
  s.email       = ["fpilz87@googlemail.com"]
  s.homepage    = "http://florianpilz.github.com/micro-optparse/"
  s.summary     = %q{An lightweight option parser, which is 80 lines short.}
  s.description = %q{This is an lightweight option parser, which is less than 80 lines short. It has strong validations and a short, clear and easy to use syntax. Feel free to copy all 80 lines (55 lines without validations / empty lines) into your script rather installing the gem.}
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.license = "MIT"
  s.has_rdoc = false
  s.add_development_dependency("rspec")
end
