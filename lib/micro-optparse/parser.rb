require 'optparse'

class Micro::Optparse::Parser
  attr_accessor :banner, :version

  def initialize(default_settings = {})
    @options = []
    @used_short = []
    @default_values = {}
    @default_settings = default_settings
    yield self if block_given?
  end

  def option(name, desc, settings = {})
    settings = @default_settings.clone.merge(settings)
    @options << {:name => name, :description => desc, :settings => settings}
  end

  def short_from(name)
    name.to_s.chars.each do |c|
      next if @used_short.include?(c) || c == "_"
      return c # returns from short_from method
    end
    return name.to_s.chars.first
  end

  def validate(result) # remove this method if you want fewer lines of code and don't need validations
    result.each_pair do |key, value|
      o = @options.find_all{ |option| option[:name] == key }.first
      key = "--" << key.to_s.gsub("_", "-")
      unless o[:settings][:value_in_set].nil? || o[:settings][:value_in_set].include?(value)
        puts "Parameter for #{key} must be in [" << o[:settings][:value_in_set].join(", ") << "]" ; exit(1)
      end
      unless o[:settings][:value_matches].nil? || o[:settings][:value_matches] =~ value
        puts "Parameter for #{key} must match /" << o[:settings][:value_matches].source << "/" ; exit(1)
      end
      unless o[:settings][:value_satisfies].nil? || o[:settings][:value_satisfies].call(value)
        puts "Parameter for #{key} must satisfy given conditions (see description)" ; exit(1)
      end
    end
  end

  def process!(arguments = ARGV)
    @result = @default_values.clone # reset or new
    @optionparser ||= OptionParser.new do |p| # prepare only once
      @options.each do |o|
        @used_short << short = o[:settings][:no_short] ? nil : o[:settings][:short] || short_from(o[:name])
        @result[o[:name]] = o[:settings][:default] || false unless o[:settings][:optional] # set default
        name = o[:name].to_s.gsub("_", "-")
        klass = o[:settings][:default].is_a?(Integer) ? Integer : o[:settings][:default].class

        args = [o[:description]]
        args << "-" + short if short
        if [TrueClass, FalseClass, NilClass].include?(klass) # boolean switch
          args << "--[no-]" + name
        else # argument with parameter, add class for typecheck
          args << "--" + name + " " + o[:settings][:default].to_s << klass
        end
        p.on(*args) {|x| @result[o[:name]] = x}
      end

      p.banner = @banner unless @banner.nil?
      p.on_tail("-h", "--help", "Show this message") {puts p ; exit}
      short = @used_short.include?("v") ? "-V" : "-v"
      p.on_tail(short, "--version", "Print version") {puts @version ; exit} unless @version.nil?
    end
    @default_values = @result.clone # save default values to reset @result in subsequent calls

    begin
      @optionparser.parse!(arguments)
    rescue OptionParser::ParseError => e
      puts e.message ; exit(1)
    end

    validate(@result) if self.respond_to?("validate")
    @result
  end

  def help!
    process! %w(--help)
  end
end
