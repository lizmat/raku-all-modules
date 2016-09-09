Change log for the Getopt::Std Perl 6 module
============================================

1.0.0.dev1 (not yet)
--------------------

- Add the Rakudo 2016.08 release to the ones tested at Travis CI.
- Do not error out on an empty option string if the :unknown or
  :nonopts flags are specified.
- Throw an X::Getopt::Std exception instead of returning false.
- Stop exporting two internal utility functions even if :util is
  specified when importing the module.
- Skip the :unknown :!all cases in the test suite.

0.1.0
-----

Initial public release.
