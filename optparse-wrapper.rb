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
  
  def option(name, desc, setting)
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
        opts[o.name] = o.default
        klass = o.default.class
        klass = Integer if klass == Fixnum
        p.on("-" << o.name.to_s.chars.first, "--" << o.name.to_s << " " << o.default.to_s, klass, o.desc) do |x|
          opts[o.name] = x
        end
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
  p.option :verbose, "set verbosity", :default => 4
  p.option :mutation, "set mutation", :default => "MightyMutation"
  p.option :chance, "set mutation chance", :default => 0.8
end.process!

puts options[:verbose]
puts options[:mutation]
puts options[:chance]