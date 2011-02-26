# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "micro-optparse/version"

Gem::Specification.new do |s|
  s.name        = "micro-optparse"
  s.version     = Micro::Optparse::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Florian Pilz"]
  s.email       = ["fpilz87@googlemail.com"]
  s.homepage    = ""
  s.summary     = %q{A very small wrapper around optparse.}
  s.description = %q{This gem wraps all the functionality of optparse into an easy to use, clear and short syntax. In addtion, strong validations are added. You can either use this gem as a lightweight alternative to trollop or copy all its 75 lines into your script to have an command-line parser without injecting a gem dependency.}

  s.license = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
