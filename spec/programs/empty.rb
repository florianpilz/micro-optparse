require "rubygems"
require_relative "../../lib/micro-optparse"

options = Micro::Optparse::Parser.new do |p|
end.process!

options.each_pair do |key, value|
  puts ":#{key} => #{value}"
end
