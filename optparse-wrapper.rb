require 'ostruct'
require 'optparse'

class Parser
  attr_accessor :banner, :version
  
  def initialize
    @options = []
    @used_short = []
    yield self
  end

  def option(name, desc, setting = {})
    option = OpenStruct.new
    option.name = name
    option.desc = desc
    option.default = setting[:default]
    option.short = setting[:short]
    @options << option
  end
  
  def determine_short(name)
    long = name.to_s.chars
    short = ""
    long.each do |c|
      short = c
      break unless @used_short.include?(short)
    end
    short
  end

  def process!
    opts = {}
    optparser = OptionParser.new do |p|
      p.banner = @banner unless @banner.nil?
      p.version = @version
      @options.each do |o|
        short = o.short || determine_short(o.name)
        @used_short << short
        opts[o.name] = o.default || false
        klass = o.default.class
        klass = Integer if klass == Fixnum
        if klass == TrueClass || klass == FalseClass || klass == NilClass
          p.on("-" << short, "--[no-]" << o.name.to_s.gsub("_", "-"), o.desc) {|x| opts[o.name] = x}
        else
          p.on("-" << short, "--" << o.name.to_s.gsub("_", "-") << " " << o.default.to_s, klass, o.desc) {|x| opts[o.name] = x}
        end
      end
      p.on_tail("-h", "--help", "Show this message") {puts p ; exit}
      short = @used_short.include?("v") ? "-V" : "-v"
      p.on_tail(short, "--version", "Print version") {puts @version ; exit} unless @version.nil?
    end
    begin
      optparser.parse!(ARGV)
    rescue OptionParser::ParseError => e
      puts e.message
      exit
    end
    opts
  end
end

options = Parser.new do |p|
  # p.banner = "test"
  p.version = "OptParseWrapper 0.8 (c) Florian Pilz 2011"
  p.option :severity, "set severity", :default => 4
  p.option :verbose, "enable verbose output"
  p.option :mutation, "set mutation", :default => "MightyMutation"
  p.option :plus_selection, "use plus-selection if set", :default => true
  p.option :selection, "selection used", :default => "BestSelection", :short => "l"
  p.option :chance, "set mutation chance", :default => 0.8
end.process!

puts options[:severity]
puts options[:verbose]
puts options[:mutation]
puts options[:plus_selection]
puts options[:selection]
puts options[:chance]