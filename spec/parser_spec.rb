require "micro-optparse"

describe Parser do
  describe "example program" do
    it "should show help message when called with --help or -h" do
      results = [`ruby spec/programs/example.rb -h`, `ruby spec/programs/example.rb --help`]
      results.each do |result|
        result.should include("--help")
        result.should include("Show this message")
      end
    end

    it "should include the banner info in the help message" do
      result = `ruby spec/programs/example.rb --help`
      result.should include("This is a banner")
    end
    
    it "should include the default banner info if no banner message was set" do
      result = `ruby spec/programs/empty_example.rb --help`
      result.should include("Usage: empty_example [options]")
    end
    
    it "should display the version when called with --version or -V" do
      # here -V is used for version, as -v is already taken for the verbose switch
      results = [`ruby spec/programs/example.rb -V`, `ruby spec/programs/example.rb --version`]
      results.each do |result|
        result.strip.should == "OptParseWrapper 0.8 (c) Florian Pilz 2011"
      end
    end
    
    it "should display the version when called with -v" do
      result = `ruby spec/programs/another_example.rb -v`
      result.strip.should == "OptParseWrapper 0.8 (c) Florian Pilz 2011"
    end
    
    it "should display a warning when --version or -v was called but no version was set" do
      results = [
        `ruby spec/programs/empty_example.rb --version 2>&1`,
        `ruby spec/programs/empty_example.rb -v 2>&1`
      ]
      results.each do |result|
        result.strip.should == "empty_example: version unknown"
      end
    end
    
    it "should display the default values if called without arguments" do
      result = `ruby spec/programs/example.rb`
      result.should include(":severity => 4")
      result.should include(":verbose => false")
      result.should include(":mutation => MightyMutation")
      result.should include(":plus_selection => true")
      result.should include(":selection => BestSelection")
      result.should include(":chance => 0.8")
    end
    
    it "should assume false as default value if no default value was given" do
      result = `ruby spec/programs/another_example.rb`
      result.should include(":eat_nothing => false")
    end
    
    it "should display overwritten values accordingly when long option names were used" do
      args = "--severity 5 --verbose --mutation DumbMutation \
              --no-plus-selection --selection WorstSelection --chance 0.1"
      result = `ruby spec/programs/example.rb #{args}`
      result.should include(":severity => 5")
      result.should include(":verbose => true")
      result.should include(":mutation => DumbMutation")
      result.should include(":plus_selection => false")
      result.should include(":selection => WorstSelection")
      result.should include(":chance => 0.1")
    end
    
    it "should display overwritten values accordingly when short option names were used" do
      # there is no short form to set switches to false
      args = "-s 5 -v -m DumbMutation --no-plus-selection -l WorstSelection -c 0.1"
      result = `ruby spec/programs/example.rb #{args}`
      result.should include(":severity => 5")
      result.should include(":verbose => true")
      result.should include(":mutation => DumbMutation")
      result.should include(":plus_selection => false")
      result.should include(":selection => WorstSelection")
      result.should include(":chance => 0.1")
    end
    
    it "should display a warning if an argument was invalid" do
      result = `ruby spec/programs/example.rb --free-beer`
      result.strip.should == "invalid option: --free-beer"
    end
    
    it "should display a warning if another argument is needed" do
      result = `ruby spec/programs/example.rb --mutation`
      result.strip.should == "missing argument: --mutation"
    end
    
    it "should display a warning if an argument of the wrong type was given" do
      result = `ruby spec/programs/example.rb --severity OMFG!!!`
      result.strip.should == "invalid argument: --severity OMFG!!!"
    end
    
    it "should display a warning if autocompletion of an argument was ambiguous" do
      result = `ruby spec/programs/example.rb --se 5`
      result.strip.should == "ambiguous option: --se"
    end
    
    it "should display a warning if validation value_in_set failed" do
      result = `ruby spec/programs/example.rb --severity 1`
      result.strip.should == "Parameter for severity must be in [4,5,6,7,8]"
    end
    
    it "should display a warning if validation value_matches failed" do
      result = `ruby spec/programs/example.rb --mutation Bazinga`
      result.strip.should == "Parameter must match /Mutation/"
    end
    
    it "should display a warning if validation value_satisfies failed" do
      result = `ruby spec/programs/example.rb --chance 300.21`
      result.strip.should == "Parameter must satisfy given conditions (see description)"
    end
    
    it "should validate all given validations" do
      result = `ruby spec/programs/another_example.rb --eat-cake VanillaBrownie`
      result.strip.should == "Parameter must match /Cake/"
      
      result = `ruby spec/programs/another_example.rb --eat-cake 2VanillaCakes`
      result.strip.should == "Parameter must satisfy given conditions (see description)"
    end
    
    it "should assign a different character for the short accessor if the first / second / ... is already taken" do
      result = `ruby spec/programs/another_example.rb --help`
      result.should include("-e, --eat-cake")
      result.should include("-a, --eat-salad")
      result.should include("-t, --eat-bagel")
      result.should include("-n, --[no]-eat-nothing")
      result.should include("-m, --eat-marshmellow")
      result.should include("--eat-me")
    end
  end
end