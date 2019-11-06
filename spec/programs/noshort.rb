require "rubygems"
require_relative "../../lib/micro-optparse"

options = Micro::Optparse::Parser.new do |p|
  p.option :foo, "Option 1", :default => "String", :no_short => true
  p.option :bar, "Option 2", :default => "String"
end.process!

options.each_pair do |key, value|
  puts ":#{key} => #{value}"
end
