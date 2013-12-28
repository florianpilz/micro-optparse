require "micro-optparse"

describe Parser do
  before(:all) do
    @evolutionary_algorithm_parser = Parser.new do |p|
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
      result[:verbose].should == false
    end
    
    it "should return default values if called without arguments" do
      result = @evolutionary_algorithm_parser.process!([])
      result[:severity].should == 4
      result[:verbose].should == false
      result[:mutation].should == "MightyMutation"
      result[:plus_selection].should == true
      result[:selection].should == "BestSelection"
      result[:chance].should == 0.8
    end
  end

  describe "setting of custom values" do
    it "should display overwritten values accordingly when long option names were used" do
      args = ["--severity", "5", "--verbose", "--mutation", "DumbMutation",
              "--no-plus-selection", "--selection", "WorstSelection", "--chance", "0.1"]
      result = @evolutionary_algorithm_parser.process!(args)
      result[:severity].should == 5
      result[:verbose].should == true
      result[:mutation].should == "DumbMutation"
      result[:plus_selection].should == false
      result[:selection].should == "WorstSelection"
      result[:chance].should == 0.1
    end
    
    it "should display overwritten values accordingly when the 'long=value' form was used" do
      args = ["--severity=5", "--mutation=DumbMutation", "--selection=WorstSelection", "--chance=0.1"]
      result = @evolutionary_algorithm_parser.process!(args)
      result[:severity].should == 5
      result[:mutation].should == "DumbMutation"
      result[:selection].should == "WorstSelection"
      result[:chance].should == 0.1
    end

    it "should display overwritten values accordingly when short option names were used" do
      # there is no short form to set switches to false
      args = ["-s", "5", "-v", "-m", "DumbMutation", "--no-plus-selection", "-l", "WorstSelection", "-c", "0.1"]
      result = @evolutionary_algorithm_parser.process!(args)
      result[:severity].should == 5
      result[:verbose].should == true
      result[:mutation].should == "DumbMutation"
      result[:plus_selection].should == false
      result[:selection].should == "WorstSelection"
      result[:chance].should == 0.1
    end
  end
  
  describe "parsing of several arrays using the same parser" do
    it "should not manipulate old results" do
      result1 = @evolutionary_algorithm_parser.process!(["--severity=5"])
      result2 = @evolutionary_algorithm_parser.process!(["--severity=6"])
      result3 = @evolutionary_algorithm_parser.process!([])

      result1[:severity].should == 5
      result2[:severity].should == 6
      result3[:severity].should == 4
    end
  end
  
  describe "empty parser" do
    it "should be allowed to create a parser with an empty block" do
      parser = Parser.new { }
      parser.should_not be_nil
      parser.class.should == Parser
    end
    
    it "should be allowed to create a parser without a block" do
      parser = Parser.new
      parser.should_not be_nil
      parser.class.should == Parser
    end
  end
  
  describe "help message" do
    it "should show help message when called with --help or -h" do
      results = [`ruby spec/programs/eating.rb -h`, `ruby spec/programs/eating.rb --help`]
      results.each do |result|
        result.should include("--help")
        result.should include("Show this message")
      end
    end
  end

  describe "banner message" do
    it "should include the banner info in the help message" do
      result = `ruby spec/programs/eating.rb --help`
      result.should include("This is a banner")
    end

    it "should include the default banner info if no banner message was set" do
      result = `ruby spec/programs/empty.rb --help`
      result.should include("Usage: empty [options]")
    end
  end

  describe "version information" do
    it "should display the version when called with --version or -V" do
      # here -V is used for version, as -v is already taken for the verbose switch
      results = [`ruby spec/programs/eating.rb -V`, `ruby spec/programs/eating.rb --version`]
      results.each do |result|
        result.strip.should == "EatingScript 1.0 (c) Florian Pilz 2011"
      end
    end

    it "should display the version when called with -v" do
      result = `ruby spec/programs/version.rb -v`
      result.strip.should == "VersionScript 0.0 (c) Florian Pilz 2011"
    end

    it "should display a warning when --version or -v was called but no version was set" do
      results = [
        `ruby spec/programs/empty.rb --version 2>&1`,
        `ruby spec/programs/empty.rb -v 2>&1`
      ]
      results.each do |result|
        result.strip.should == "empty: version unknown"
      end
    end
  end

  describe "warnings from optparse" do
    it "should display a warning if an argument was invalid" do
      result = `ruby spec/programs/eating.rb --free-beer`
      result.strip.should == "invalid option: --free-beer"
    end

    it "should display a warning if another argument is needed" do
      result = `ruby spec/programs/eating.rb --eat-cake`
      result.strip.should == "missing argument: --eat-cake"
    end

    it "should display a warning if an argument of the wrong type was given" do
      result = `ruby spec/programs/eating.rb --eat-marshmellows OMFG!!!`
      result.strip.should == "invalid argument: --eat-marshmellows OMFG!!!"
    end

    it "should display a warning if autocompletion of an argument was ambiguous" do
      result = `ruby spec/programs/eating.rb --eat yummy!`
      result.strip.should == "ambiguous option: --eat"
    end
  end

  describe "warnings if validation failed" do
    it "should display a warning if validation value_in_set failed" do
      result = `ruby spec/programs/eating.rb --eat-bagel AshBagel`
      result.strip.should match(/Parameter for --eat-bagel must be in \[SalmonBagel,\s?ParmesanBagel\]/)
    end

    it "should display a warning if validation value_matches failed" do
      result = `ruby spec/programs/eating.rb --eat-cake Chocolate`
      result.strip.should == "Parameter for --eat-cake must match /Cake/"
    end

    it "should display a warning if validation value_satisfies failed" do
      result = `ruby spec/programs/eating.rb --eat-cake 12Cakes`
      result.strip.should == "Parameter for --eat-cake must satisfy given conditions (see description)"
    end

    it "should validate all validations if several are given for an option" do
      result = `ruby spec/programs/eating.rb --eat-cake VanillaBrownie`
      result.strip.should == "Parameter for --eat-cake must match /Cake/"

      result = `ruby spec/programs/eating.rb --eat-cake 2VanillaCakes`
      result.strip.should == "Parameter for --eat-cake must satisfy given conditions (see description)"
    end
  end

  describe "automatic assignment of default accessors" do
    it "should assign a different character for the short accessor if the first / second / ... is already taken" do
      result = `ruby spec/programs/eating.rb --help`
      result.should include("--eat-cake")
      result.should include("-a, --eat-salad")
      result.should include("-t, --eat-bagel")
      result.should include("-n, --[no-]eat-nothing")
      result.should include("-m, --eat-marshmellow")
      result.should include("-e, --eat-me")
    end
  end

  describe "assigns short for every param" do
    it "should use every short only once" do
      result  = `ruby spec/programs/short.rb --help`
      result.scan(/\s-a/).length.should == 1
      result.scan(/\s-b/).length.should == 1
      result.scan(/\s-c/).length.should == 1
    end

    it "should use first char as short if all have been used" do
      result  = `ruby spec/programs/short.rb --help`
      result.should include("-a, --acb")
      result.should include("-b, --bac")
      result.should include("-c, --cba")
    end
  end
end