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
    
    it "should display the version when called with --version or -V" do
      # here -V is used for version, as -v is already taken for the verbose switch
      results = [`ruby spec/programs/example.rb -V`, `ruby spec/programs/example.rb --version`]
      results.each do |result|
        result.strip.should == "OptParseWrapper 0.8 (c) Florian Pilz 2011"
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
  end
end