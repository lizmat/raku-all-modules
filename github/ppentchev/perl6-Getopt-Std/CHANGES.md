Change log for the Getopt::Std Perl 6 module
============================================

1.0.1
-----

- Support non-alphanumeric characters as option characters, e.g.
  let a "-:" option string be used to sort of support long options
  such as "--help" and "--version".

1.0.0
-----

- Do not error out on an empty option string if the :unknown or
  :nonopts flags are specified.
- Throw an X::Getopt::Std exception instead of returning false.
  Incidentally, closes: #2; thanks, Tom Browder!
- Stop exporting two internal utility functions even if :util is
  specified when importing the module.
- Skip the :unknown :!all cases in the test suite.
- Remove the :all flag and split it out into the getopts-all()
  function instead, if only to be able to predict the type of
  the returned options array.  Closes: #1; thanks, Tom Browder!
- Update the Travis CI build:
  - build on the 2017.{06,07,08,09} Rakudo Perl 6 releases
  - do not test building with "panda"
- Merge Samantha McVey's pull request #1 to specify
  the Artistic-2.0 license in META6.json.

0.1.0
-----

Initial public release.
