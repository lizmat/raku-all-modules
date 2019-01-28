# XDG::BaseDirectory

Perl 6 access to path information provided by the xdg base directory
specfication http://www.freedesktop.org/wiki/Specifications/basedir-spec/.

[![Build Status](https://travis-ci.org/jonathanstowe/XDG-BaseDirectory.svg?branch=master)](https://travis-ci.org/jonathanstowe/XDG-BaseDirectory)

## Synopsis

```perl6

    use XDG::BaseDirectory;

    my $bd = XDG::BaseDirectory.new

    for $bd.load-config-paths('mydomain.org', 'MyProg', 'Options') -> $d {
        say $d;
    }

```

## Description

This is loosely based on the interface of python module pyxdg. But
due to the differences between Python and Perl 6 it may do some things
differently.

It provides a set of facilities for discovering the location of the
configuration and data of applications.

I split this out from the XDG module as it has more general usefulness
and no external dependencies.

## Installation

Assuming you have a working Rakudo Perl 6 installation with *zef*
installed you can install from a copy of the source directory:

     zef install .

or remotely:

     zef install XDG::BaseDirectory 

## Support

Suggestions/patches are welcomed via github at:

   https://github.com/jonathanstowe/XDG-BaseDirectory/issues

I'm not able to test on a wide variety of platforms so any help there
would be appreciated.

## Licence

This module is Free Software please see the [LICENCE](LICENCE) file in the 
distribution for the exact terms.

© Jonathan Stowe 2015, 2016, 2017, 2018, 2019
