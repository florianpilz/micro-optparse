require "rubygems"
require_relative "../../lib/micro-optparse"

options = Micro::Optparse::Parser.new do |p|
  p.version = "EatingScript 1.0 (c) Florian Pilz 2011"
  p.banner = "This is a banner"
  p.option :verbose, "Switch on verbosity"
  p.option :eat_cake, "Eath the yummy cake!", :default => "PlainCake", :value_matches => /Cake/, :value_satisfies => lambda { |arg| arg.to_i == 0 }
  p.option :eat_salad, "It's healty!", :default => "CucumberSalad"
  p.option :eat_bagel, "You should try it with salmon.", :default => "SalmonBagel", :value_in_set => ["SalmonBagel", "ParmesanBagel"]
  p.option :eat_nothing, "Stupid decision ..."
  p.option :eat_marshmellows, "How many?", :default => 0
  p.option :eat_me, "WHAT?!?", :default => "TastyHuman"
end.process!

options.each_pair do |key, value|
  puts ":#{key} => #{value}"
end
