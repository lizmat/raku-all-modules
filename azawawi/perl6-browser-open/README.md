# Browser::Open [![Build Status](https://travis-ci.org/azawawi/perl6-browser-open.svg?branch=master)](https://travis-ci.org/azawawi/perl6-browser-open) [![Build status](https://ci.appveyor.com/api/projects/status/github/azawawi/perl6-browser-open?svg=true)](https://ci.appveyor.com/project/azawawi/perl6-browser-open/branch/master)

This is a humble Perl 6 port of Perl's [Browser::Open](http://metacpan.org/module/Browser::Open).

## Installation

To install it using Panda (a module management tool bundled with Rakudo Star):

```
$ panda update
$ panda install Browser::Open
```

## Synopsis

```Perl6
use Browser::Open;

my $ok = open_browser($url);
```

## Description

The functions optionally exported by this module allows you to open URLs in the user browser.

A set of known commands per OS-name is tested for presence, and the first one found is executed. With an optional parameter, all known commands are checked.

## Testing

To run tests:

```
$ prove -e "perl6 -Ilib"
```

## Author

Ahmad M. Zawawi, azawawi on #perl6, https://github.com/azawawi/

## License

MIT License
