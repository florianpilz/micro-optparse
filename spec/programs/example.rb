require "rubygems"
require "micro-optparse"

options = Parser.new do |p|
  p.banner = "This is a banner"
  p.version = "OptParseWrapper 0.8 (c) Florian Pilz 2011"
  p.option :severity, "set severity", :default => 4, :value_in_set => [4,5,6,7,8]
  p.option :verbose, "enable verbose output"
  p.option :mutation, "set mutation", :default => "MightyMutation", :value_matches => /Mutation/
  p.option :plus_selection, "use plus-selection if set", :default => true
  p.option :selection, "selection used", :default => "BestSelection", :short => "l"
  p.option :chance, "set mutation chance", :default => 0.8, :value_satisfies => lambda {|x| x >= 0.0 && x <= 1.0}
end.process!

options.each_pair do |key, value|
  puts ":#{key} => #{value}"
end