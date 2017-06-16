require "rubygems"
require_relative "../../lib/micro-optparse"

options = Parser.new do |p|
end.process!

options.each_pair do |key, value|
  puts ":#{key} => #{value}"
end
