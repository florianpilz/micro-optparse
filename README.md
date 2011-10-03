&micro;-optparse
==========

Why another command line parser?
--------------------------------

There are lots of command line parser out there, for example [trollop](http://trollop.rubyforge.org/) is a great alternative.
However, it is 800 lines long.
In addition, trollop sucks at validating the input.
So &micro;-optparse is for you if you are looking for

* a small command line parser to copy and paste it into your scripts to avoid injecting gem-dependencies
* a command line parser with powerful validations
* an easily usable, understandable and extendable command line parser
* a wrapper around optparse, which intelligently fills out most informations on its own

What is &micro;-optparse?
-------------------

&micro;-optparse is a small wrapper around [optparse](http://www.ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html), weighing **less than 75 lines of code**.
optparse (or OptionParser) on the other hand is a command line parser, which ships with ruby.
After you defined available options, it automatically creates a help page and is able to parse ARGV accordingly.
However, optparse requires you to repeat yourself quite often, which leads to many lines of code, just to configure the available options.
&micro;-optparse removes this obstacle by extracting the information contained in few lines of configuration.
In addition, &micro;-optparse extends optparse by some **powerful validations**, which where inspired by [OptiFlag](http://optiflag.rubyforge.org/quick.html).

Talk in code!
-------------

    require 'rubygems' # necessary for ruby v1.8.*
    require 'micro-optparse'
    options = Parser.new do |p|
       p.banner = "This is a fancy script, for usage see below"
       p.version = "fancy script 0.0 alpha"
       p.option :severity, "set severity", :default => 4, :value_in_set => [4,5,6,7,8]
       p.option :verbose, "enable verbose output"
       p.option :mutation, "set mutation", :default => "MightyMutation", :value_matches => /Mutation/
       p.option :plus_selection, "use plus-selection if set", :default => true
       p.option :selection, "selection used", :default => "BestSelection", :short => "l"
       p.option :chance, "set mutation chance", :default => 0.8, :value_satisfies => lambda {|x| x >= 0.0 && x <= 1.0}
    end.process!

What this piece of code does is the following:

* it creates a help message and help options, with the banner above the options
* it creates a version option, which displays the given text
* it creates a long accessor for each option, according to the symbol - for example `"--verbose"` for `:verbose`
* it crease a short accessor, which is the first character of the long accessor (automatically resolves duplicates)
* it checks if the class of the input and the default value match
* it creates a switch, if no default value exist or the default value is `true` or `false`
* when value\_in\_set is given, it validates if the input value is in the given array
* when value_matches is given, it validates if the input value matches the regular expression
* when value_satisfies is given, it validates if the lamda or Proc evaluates to `true`, when fed with the input value
* it stores all parsed arguments and default values in the options hash, i.e. to access the value of `:mutation` in your script, write `options[:mutation]`

The automatically generated help message looks like this:

    This is a fancy script, for usage see below
        -s, --severity 4                 set severity
        -v, --[no-]verbose               enable verbose output
        -m, --mutation MightyMutation    set mutation
        -p, --[no-]plus-selection        use plus-selection if set
        -l, --selection BestSelection    selection used
        -c, --chance 0.8                 set mutation chance
        -h, --help                       Show this message
        -V, --version                    Print version

It doesn't stop at the command line!
------------------------------------

&micro;-optparse can parse any array which is formatted like ARGV, e.g. `["--severity", "4"]` is the same as typing `"--severity 4"` behind your program call.
You can even process several arrays with the same parser (see example below).
In addition, you don't need to specify all options at once, i.e. you can pass the parser around and add more options until you call the `process!`-method.

    require 'rubygems' # necessary for ruby v1.8.*
    require 'micro-optparse'
    
    parser = Parser.new
    parser.option :eat_snickers, "How many?", :default => 0
    options1 = parser.process!(["--eat-snickers", "2"])
    options2 = parser.process!(["--eat-snickers", "1"])

Where do I get &micro;-optparse?
--------------------------

You can either go and install the gem via `gem install micro-optparse` or grab it from [this repository](https://github.com/florianpilz/micro-optparse/blob/master/lib/micro-optparse/parser.rb) and paste it into your script.
If you choose the latter option, you may delete the `validate`-method to spare another 15 lines of code.

If you want to contribute, you can fork this repository, make your changes and send me a pull request.
However, improvements must be one of the following:

* use fewer lines of code, without sacrificing readablity or functionality
* enhance readablity or functionality, without increasing the lines of code

Frequently Asked Questions
--------------------------

### All my argument values are either true or false - what's wrong?
You must define default values, if the option should accept an argument. Every option without a default value (or with `true` or `false` as default) is treated as a switch: true if given and false / default otherwise.

### Is it possible to define mandatory / required arguments, which must be provided?
No it's not. It should be possible in any case to provide a reasonable default value. If you come across a case where it's not possible, feel free to contact me.

### Are long arguments with spaces and other special characters allowed?
Yes, just define an option which takes a `String` as an argument, i.e. pass a string as the default value for that option. Now everything between quotes will be parsed as the value for that argument, e.g. `ruby testscript.rb --selection 'I want the best selection you have!!! And if possible, add Donuts.'` Note that double quotes may cause trouble, for example I get an error if I use an exclamation mark in double quotes, but no error in single quotes.

### Is it possible to define arguments which accept lists / arrays / multiple files / ... ?
Yes, just define an option which takes an `Array` as an argument, i.e. pass an array as the default value for that option. The input will be split by comma. If the arguments contain spaces, wrap the whole thing in single quotes or double quotes.

For example if you want to accept multiple file names with whitespaces in them:

    require 'rubygems' # necessary for ruby v1.8.*
    require 'micro-optparse'
    
    options = Parser.new do |p|
      p.option :filenames, "Files which will be processed", :default => []
    end.process!
    
    p options[:filenames]
&nbsp;

    ruby testscript.rb --filenames 'todo.txt,my great adventures.txt'
    => ["todo.txt", "my great adventures.txt"]