# File::HomeDir
[![Build Status](https://travis-ci.org/azawawi/File-HomeDir.svg?branch=master)](https://travis-ci.org/azawawi/File-HomeDir)

This is a Perl 6 port of https://metacpan.org/pod/File::HomeDir. File::HomeDir
is a module for locating the directories that are "owned" by a user (typicaly
your user) and to solve the various issues that arise trying to find them
consistently across a wide variety of platforms.

The end result is a single API that can find your resources on any platform,
making it relatively trivial to create Perl software that works elegantly and
correctly no matter where you run it.

## Installation

To install it using Panda (a module management tool bundled with Rakudo Star):

    panda update
    panda install File::HomeDir

## Testing

To run tests:

    prove -e perl6

## Author

Perl 6 version:
- Ahmad M. Zawawi, azawawi on #perl6, https://github.com/azawawi/
- Tadeusz Sośnierz, tadzik on #perl6, https://github.com/tadzik/

Perl 5 version:
- Adam Kennedy (2005 - 2012)
- Chris Nandor (2006)
- Stephen Steneker (2006)
- Jérôme Quelin (2009-2011)
- Sean M. Burke (2000)

## License

Artistic License 2.0
