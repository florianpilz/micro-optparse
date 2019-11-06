require "rubygems"
require_relative "../../lib/micro-optparse"

options = Micro::Optparse::Parser.new do |p|
  p.option :abc, "Option 1", :default => "String"
  p.option :bca, "Option 2", :default => "String"
  p.option :cab, "Option 3", :default => "String"
  # all shorts used up, futher shorts overwrite previous ones
  p.option :bac, "Option 4", :default => "String"
  p.option :acb, "Option 5", :default => "String"
  p.option :cba, "Option 6", :default => "String"
end.process!

options.each_pair do |key, value|
  puts ":#{key} => #{value}"
end
