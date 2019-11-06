require_relative "../lib/micro-optparse"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

describe Micro::Optparse::Parser do
  before(:all) do
    @evolutionary_algorithm_parser = Micro::Optparse::Parser.new do |p|
      p.option :severity, "set severity", :default => 4, :value_in_set => [4,5,6,7,8]
      p.option :verbose, "enable verbose output"
      p.option :mutation, "set mutation", :default => "MightyMutation", :value_matches => /Mutation/
      p.option :plus_selection, "use plus-selection if set", :default => true
      p.option :selection, "selection used", :default => "BestSelection", :short => "l"
      p.option :chance, "set mutation chance", :default => 0.8, :value_satisfies => lambda {|x| x >= 0.0 && x <= 1.0}
    end
  end

  describe "parsing of default values" do
    it "should assume false as default value if no default value was given" do
      result = @evolutionary_algorithm_parser.process!([])
      expect(result[:verbose]).to eql false
    end

    it "should return default values if called without arguments" do
      result = @evolutionary_algorithm_parser.process!([])
      expect(result[:severity]).to eql 4
      expect(result[:verbose]).to eql false
      expect(result[:mutation]).to eql "MightyMutation"
      expect(result[:plus_selection]).to eql true
      expect(result[:selection]).to eql "BestSelection"
      expect(result[:chance]).to eql 0.8
    end

    it "should not return a default value if the argument is declared optional" do
      parser = Micro::Optparse::Parser.new do |p|
        p.option :optarg, "optional argument", :optional => true
      end
      result = parser.process!()
      expect(result.has_key?(:optarg)).to eql false
      expect(result[:optarg]).to eql nil
    end
  end

  describe "setting of custom values" do
    it "should display overwritten values accordingly when long option names were used" do
      args = ["--severity", "5", "--verbose", "--mutation", "DumbMutation",
              "--no-plus-selection", "--selection", "WorstSelection", "--chance", "0.1"]
      result = @evolutionary_algorithm_parser.process!(args)
      expect(result[:severity]).to eql 5
      expect(result[:verbose]).to eql true
      expect(result[:mutation]).to eql "DumbMutation"
      expect(result[:plus_selection]).to eql false
      expect(result[:selection]).to eql "WorstSelection"
      expect(result[:chance]).to eql 0.1
    end

    it "should display overwritten values accordingly when the 'long=value' form was used" do
      args = ["--severity=5", "--mutation=DumbMutation", "--selection=WorstSelection", "--chance=0.1"]
      result = @evolutionary_algorithm_parser.process!(args)
      expect(result[:severity]).to eql 5
      expect(result[:mutation]).to eql "DumbMutation"
      expect(result[:selection]).to eql "WorstSelection"
      expect(result[:chance]).to eql 0.1
    end

    it "should display overwritten values accordingly when short option names were used" do
      # there is no short form to set switches to false
      args = ["-s", "5", "-v", "-m", "DumbMutation", "--no-plus-selection", "-l", "WorstSelection", "-c", "0.1"]
      result = @evolutionary_algorithm_parser.process!(args)
      expect(result[:severity]).to eql 5
      expect(result[:verbose]).to eql true
      expect(result[:mutation]).to eql "DumbMutation"
      expect(result[:plus_selection]).to eql false
      expect(result[:selection]).to eql "WorstSelection"
      expect(result[:chance]).to eql 0.1
    end
  end

  describe "parsing of several arrays using the same parser" do
    it "should not manipulate old results" do
      result1 = @evolutionary_algorithm_parser.process!(["--severity=5"])
      result2 = @evolutionary_algorithm_parser.process!(["--severity=6"])
      result3 = @evolutionary_algorithm_parser.process!([])

      expect(result1[:severity]).to eql 5
      expect(result2[:severity]).to eql 6
      expect(result3[:severity]).to eql 4
    end
  end

  describe "empty parser" do
    it "should be allowed to create a parser with an empty block" do
      parser = Micro::Optparse::Parser.new { }
      expect(parser).not_to be_nil
      expect(parser.class).to eql Micro::Optparse::Parser
    end

    it "should be allowed to create a parser without a block" do
      parser = Micro::Optparse::Parser.new
      expect(parser).not_to be_nil
      expect(parser.class).to eql Micro::Optparse::Parser
    end
  end

  describe "parsing of lists" do
    it "should parse list of arguments separated by comma when given an array as default" do
      parser = Micro::Optparse::Parser.new do |p|
        p.option :listarg, "List Argument", :default => []
      end

      input = ['--listarg', 'foo,bar,baz']
      expect(parser.process!(input)[:listarg]).to eql ['foo', 'bar', 'baz']
    end

    it "should allow multiple argument lists" do
      parser = Micro::Optparse::Parser.new do |p|
        p.option :first_listarg, "List Argument", :default => []
        p.option :second_listarg, "List Argument", :default => []
      end

      input = ['-f', 'foo,bar,baz', '-s', 'blah,blah,blah']
      result = parser.process!(input)
      expect(result[:first_listarg]).to eql ['foo', 'bar', 'baz']
      expect(result[:second_listarg]).to eql ['blah', 'blah', 'blah']
    end
  end

  describe "default settings" do
    it "should set default settings on all options" do
      parser = Micro::Optparse::Parser.new(:optional => true) do |p|
        p.option :foo, "foo argument"
        p.option :bar, "bar argument"
      end

      result = parser.process!([])
      expect(result.length).to eql 0 # all optional
    end

    it "should allow to overwrite default settings" do
      parser = Micro::Optparse::Parser.new(:default => "Bar") do |p|
        p.option :foo, "foo argument", :default => "Foo"
        p.option :bar, "bar argument"
      end

      result = parser.process!([])
      expect(result[:foo]).to eql "Foo"
      expect(result[:bar]).to eql "Bar"
    end
  end

  describe "help message" do
    it "should show help message when called with --help or -h" do
      results = [`ruby spec/programs/eating.rb -h`, `ruby spec/programs/eating.rb --help`]
      results.each do |result|
        expect(result).to include("--help")
        expect(result).to include("Show this message")
      end
    end
  end

  describe "banner message" do
    it "should include the banner info in the help message" do
      result = `ruby spec/programs/eating.rb --help`
      expect(result).to include("This is a banner")
    end

    it "should include the default banner info if no banner message was set" do
      result = `ruby spec/programs/empty.rb --help`
      expect(result).to include("Usage: empty [options]")
    end
  end

  describe "version information" do
    it "should display the version when called with --version or -V" do
      # here -V is used for version, as -v is already taken for the verbose switch
      results = [`ruby spec/programs/eating.rb -V`, `ruby spec/programs/eating.rb --version`]
      results.each do |result|
        expect(result.strip).to eql "EatingScript 1.0 (c) Florian Pilz 2011"
      end
    end

    it "should display the version when called with -v" do
      result = `ruby spec/programs/version.rb -v`
      expect(result.strip).to eql "VersionScript 0.0 (c) Florian Pilz 2011"
    end

    it "should display a warning when --version or -v was called but no version was set" do
      results = [
        `ruby spec/programs/empty.rb --version 2>&1`,
        `ruby spec/programs/empty.rb -v 2>&1`
      ]
      results.each do |result|
        expect(result.strip).to eql "empty: version unknown"
      end
    end
  end

  describe "warnings from optparse" do
    it "should display a warning if an argument was invalid" do
      result = `ruby spec/programs/eating.rb --free-beer`
      expect(result.strip).to eql "invalid option: --free-beer"
    end

    it "should display a warning if another argument is needed" do
      result = `ruby spec/programs/eating.rb --eat-cake`
      expect(result.strip).to eql "missing argument: --eat-cake"
    end

    it "should display a warning if an argument of the wrong type was given" do
      result = `ruby spec/programs/eating.rb --eat-marshmellows OMFG!!!`
      expect(result.strip).to eql "invalid argument: --eat-marshmellows OMFG!!!"
    end

    it "should display a warning if autocompletion of an argument was ambiguous" do
      result = `ruby spec/programs/eating.rb --eat yummy!`
      expect(result.strip).to eql "ambiguous option: --eat"
    end
  end

  describe "warnings if validation failed" do
    it "should display a warning if validation value_in_set failed" do
      result = `ruby spec/programs/eating.rb --eat-bagel AshBagel`
      expect(result.strip).to match(/Parameter for --eat-bagel must be in \[SalmonBagel,\s?ParmesanBagel\]/)
    end

    it "should display a warning if validation value_matches failed" do
      result = `ruby spec/programs/eating.rb --eat-cake Chocolate`
      expect(result.strip).to eql "Parameter for --eat-cake must match /Cake/"
    end

    it "should display a warning if validation value_satisfies failed" do
      result = `ruby spec/programs/eating.rb --eat-cake 12Cakes`
      expect(result.strip).to eql "Parameter for --eat-cake must satisfy given conditions (see description)"
    end

    it "should validate all validations if several are given for an option" do
      result = `ruby spec/programs/eating.rb --eat-cake VanillaBrownie`
      expect(result.strip).to eql "Parameter for --eat-cake must match /Cake/"

      result = `ruby spec/programs/eating.rb --eat-cake 2VanillaCakes`
      expect(result.strip).to eql "Parameter for --eat-cake must satisfy given conditions (see description)"
    end
  end

  describe "automatic assignment of default accessors" do
    it "should assign a different character for the short accessor if the first / second / ... is already taken" do
      result = `ruby spec/programs/eating.rb --help`
      expect(result).to include("--eat-cake")
      expect(result).to include("-a, --eat-salad")
      expect(result).to include("-t, --eat-bagel")
      expect(result).to include("-n, --[no-]eat-nothing")
      expect(result).to include("-m, --eat-marshmellow")
      expect(result).to include("-e, --eat-me")
    end
  end

  describe "assigns short for every param" do
    it "should use every short only once" do
      result  = `ruby spec/programs/short.rb --help`
      expect(result.scan(/\s-a/).length).to eql 1
      expect(result.scan(/\s-b/).length).to eql 1
      expect(result.scan(/\s-c/).length).to eql 1
    end

    it "should use first char as short if all have been used" do
      result  = `ruby spec/programs/short.rb --help`
      expect(result).to include("-a, --acb")
      expect(result).to include("-b, --bac")
      expect(result).to include("-c, --cba")
    end

    it "should be possible to prevent creation of short arguments" do
      result  = `ruby spec/programs/noshort.rb --help`
      expect(result).not_to include("-f, --foo")
      expect(result).to include("--foo")
      expect(result).to include("-b, --bar")
    end
  end
end
