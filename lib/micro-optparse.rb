require 'micro-optparse/parser'
# 
# options = Parser.new do |p|
#   # p.banner = "test"
#   p.version = "OptParseWrapper 0.8 (c) Florian Pilz 2011"
#   p.option :severity, "set severity", :default => 4, :value_in_set => [4,5,6,7,8]
#   p.option :verbose, "enable verbose output"
#   p.option :mutation, "set mutation", :default => "MightyMutation", :value_matches => /Mutation/
#   p.option :plus_selection, "use plus-selection if set", :default => true
#   p.option :selection, "selection used", :default => "BestSelection"#, :short => "l"
#   p.option :chance, "set mutation chance", :default => 0.8, :value_satisfies => lambda {|x| x >= 0.0 && x <= 1.0}
# end.process!
# 
# puts options[:severity]
# puts options[:verbose]
# puts options[:mutation]
# puts options[:plus_selection]
# puts options[:selection]
# puts options[:chance]