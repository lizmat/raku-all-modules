# Test::Junkie

## Continuous test runner for Perl 6
Requires a recent version of Rakudo (after April 21st, 2012) for updates IO.pm
changetime detection. Currently depends on Perl 5 prove as a testrunner.

## Background
**junk·ie** *noun* \ˈjəŋ-kē\ - a person who derives inordinate pleasure from or who is dependent on something *(in this case testing)*

The initial version was developed as a part of the Perl 6 patterns hackathon in Oslo, and based on masak's mini-tote Gist for all functionality. See: https://gist.github.com/834500

##Planned extensions

- pluggable implementations for running tests
- pluggable implementations for reporting 
- separate running from reporting
- option to 'make' before running tests in order to update blib/lib (should be useful for modules already installed
