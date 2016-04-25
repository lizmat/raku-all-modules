# File::HomeDir
[![Build Status](https://travis-ci.org/azawawi/perl6-file-homedir.svg?branch=master)](https://travis-ci.org/azawawi/perl6-file-homedir) [![Build status](https://ci.appveyor.com/api/projects/status/github/azawawi/perl6-file-homedir?svg=true)](https://ci.appveyor.com/project/azawawi/perl6-file-homedir/branch/master)

This is a Perl 6 port of [File::HomeDir](https://metacpan.org/pod/File::HomeDir).
File::HomeDir is a module for locating the directories that are "owned" by a
user (typicaly your user) and to solve the various issues that arise trying to
find them consistently across a wide variety of platforms.

The end result is a single API that can find your resources on any platform,
making it relatively trivial to create Perl software that works elegantly and
correctly no matter where you run it.

## Example

```Perl6
use v6;

use File::HomeDir;

say File::HomeDir.my-home;
say File::HomeDir.my-desktop;
say File::HomeDir.my-documents;
say File::HomeDir.my-pictures;
say File::HomeDir.my-videos;
```

## Installation

To install it using Panda (a module management tool bundled with Rakudo Star):

    panda update
    panda install File::HomeDir

## Testing

To run tests:

    prove -v -e "perl6 -Ilib"

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

MIT License
