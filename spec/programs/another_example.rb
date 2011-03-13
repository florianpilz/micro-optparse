require "rubygems"
require "micro-optparse"

options = Parser.new do |p|
  p.version = "OptParseWrapper 0.8 (c) Florian Pilz 2011"
  p.option :eat_cake, "Eath the yummy cake!", :default => "PlainCake", :value_in_set => ["PlainCake", "VanillaCake"], :value_matches => /Cake/, :value_satisfies => lambda { |arg| arg.to_i == 0 }
  p.option :eat_salad, "It's healty!", :default => "CucumberSalad"
  p.option :eat_bagel, "You should try it with salmon.", :default => "SalmonBagel"
end.process!

options.each_pair do |key, value|
  puts ":#{key} => #{value}"
end