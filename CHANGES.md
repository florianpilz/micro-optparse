Version History
===============

Version 1.2.1 (2017-10-02)
--------------------------

* Adjusted parsing of default values to look for `Integer` rather `Fixnum`
  to be compatible with Ruby 2.4.0.

Version 1.2.0 (2013-12-29)
--------------------------

* Fixed bug which raised an error in ruby 2.0, when all chars for the short
  accessor had already been used

* Added argument setting `:optional => true`, so argument will only appear in
  the parsed option if given by the user, thus it will not be filled using
  the default value

* Added argument setting `:no_short => true`, to prevent the creation of an
  short accessor for the argument

* Added possibility to define default settings when creating the Parser,
  for example to prevent creation of short accessors for ALL arguments easily

* Added some more tests and improved readability
