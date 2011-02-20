require 'ostruct'
require 'optparse'

class Parser
  def initialize
    @options = []
    yield self
  end

  def banner(text)
    @banner = text
  end

  def option(name, desc, setting = {})
    option = OpenStruct.new
    option.name = name
    option.desc = desc
    option.default = setting[:default]
    @options << option
  end

  def process!
    opts = {}
    optparser = OptionParser.new do |p|
      p.banner = @banner
      @options.each do |o|
        opts[o.name] = o.default || false
        klass = o.default.class
        klass = Integer if klass == Fixnum
        if klass == TrueClass || klass == FalseClass || klass == NilClass
          p.on("-" << o.name.to_s.chars.first, "--[no-]" << o.name.to_s.gsub("_", "-"), o.desc) {|x| opts[o.name] = x}
        else
          p.on("-" << o.name.to_s.chars.first, "--" << o.name.to_s.gsub("_", "-") << " " << o.default.to_s, klass, o.desc) {|x| opts[o.name] = x}
        end
      end
      p.on_tail("-h", "--help", "Show this message") do
        puts p
        exit
      end
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
  p.banner "test"
  p.option :severity, "set severity", :default => 4
  p.option :verbose, "enable verbose output"
  p.option :mutation, "set mutation", :default => "MightyMutation"
  p.option :plus_selection, "use plus-selection if set", :default => true
  p.option :chance, "set mutation chance", :default => 0.8
end.process!

puts options[:severity]
puts options[:verbose]
puts options[:mutation]
puts options[:plus_selection]
puts options[:chance]