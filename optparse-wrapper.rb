require 'ostruct'
require 'optparse'

class Parser
  def initialize
    @options = []
    yield self
    process!
  end
  
  def banner(text)
    @banner = text
  end
  
  def process!
    optparser = OptionParser.new do |p|
      p.banner = @banner
    end
    optparser.parse!
  end
end

options = Parser.new do |p|
  p.banner "test"
end