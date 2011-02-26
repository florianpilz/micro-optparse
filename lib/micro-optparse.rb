require 'ostruct'
require 'optparse'

module Micro
  class Optparse
    attr_accessor :banner, :version

    def initialize
      @options = []
      @used_short = []
      yield self
    end

    def option(name, desc, settings = {})
      @options << [name, desc, settings]
    end

    def short_from(name)
      name.to_s.chars.each do |c|
        next if @used_short.include?(c)
        return c # returns from short_from method
      end
    end

    def validate(options) # remove this method and call in process! if you don't need validations
      options.each_pair do |key, value|
        opt = nil
        @options.each { |o| opt = o if o[0] == key }
        unless opt[2][:value_in_set].nil? || opt[2][:value_in_set].include?(value)
          puts "Parameter for " << key.to_s << " must be in [" << opt[2][:value_in_set].join(",") << "]" ; exit(1)
        end
        unless opt[2][:value_matches].nil? || opt[2][:value_matches] =~ value
          puts "Parameter must match /" << opt[2][:value_matches].source << "/" ; exit(1)
        end
        unless opt[2][:value_satisfies].nil? || opt[2][:value_satisfies].call(value)
          puts "Parameter must satisfy given conditions (see description)" ; exit(1)
        end
      end
    end

    def process!
      options = {}
      optionparser = OptionParser.new do |p|
        @options.each do |o|
          @used_short << short = o[2][:short] || short_from(o[0])
          options[o[0]] = o[2][:default] || false # set default
          klass = o[2][:default].class == Fixnum ? Integer : o[2][:default].class

          if klass == TrueClass || klass == FalseClass || klass == NilClass # boolean switch
            p.on("-" << short, "--[no-]" << o[0].to_s.gsub("_", "-"), o[1]) {|x| options[o[0]] = x}
          else # argument with parameter
            p.on("-" << short, "--" << o[0].to_s.gsub("_", "-") << " " << o[2][:default].to_s, klass, o[1]) {|x| options[o[0]] = x}
          end
        end

        p.banner = @banner unless @banner.nil?
        p.on_tail("-h", "--help", "Show this message") {puts p ; exit}
        short = @used_short.include?("v") ? "-V" : "-v"
        p.on_tail(short, "--version", "Print version") {puts @version ; exit} unless @version.nil?
      end

      begin
        optionparser.parse!(ARGV)
      rescue OptionParser::ParseError => e
        puts e.message ; exit(1)
      end

      validate(options)
      options
    end
  end
end
# 
# options = Micro::Optparse.new do |p|
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