Change log for the Shell-Capture Perl 6 module
==============================================

0.2.3
=====

- Bump the version so that it is actually indexed.

0.2.2
=====

- Move the "use v6.c" statement to the first line of the file.
  Thanks to Aleks-Daniel Jakimenko-Aleksejev <alex.jakimenko@gmail.com>
- Test with recent versions of Perl 6.

0.2.1
-----

- Test against the four most recent Rakudo Perl 6 releases on Travis CI.
- Merge Samantha McVey's pull request #1 to specify
  the Artistic-2.0 license in META6.json.

0.2.0
-----

- also test against the 2016.07.1 and 2016.08.1 Rakudo releases on
  Travis CI
- add the `$enc` and `$nl` parameters to both `capture()` and `capture-check()`,
  optionally specifying the encoding and the newline delimiter in
  the external program's output

0.1.0
-----

- first public release
