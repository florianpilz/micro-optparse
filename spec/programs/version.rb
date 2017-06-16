require "rubygems"
require_relative "../../lib/micro-optparse"

options = Parser.new do |p|
  p.version = "VersionScript 0.0 (c) Florian Pilz 2011"
end.process!

options.each_pair do |key, value|
  puts ":#{key} => #{value}"
end
