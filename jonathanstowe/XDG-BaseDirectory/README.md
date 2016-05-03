# XDG::BaseDirectory

Perl 6 access to path information provided by the xdg base directory
specfication http://www.freedesktop.org/wiki/Specifications/basedir-spec/.

[![Build Status](https://travis-ci.org/jonathanstowe/XDG-BaseDirectory.svg?branch=master)](https://travis-ci.org/jonathanstowe/XDG-BaseDirectory)


## Description

This is loosely based on the interface of python module pyxdg. But
due to the differences between Python and Perl 6 it may do some things
differently.

It provides a set of facilities for discovering the location configuration
and data of applications.

I split this out from the XDG module as it has more general usefulness
and no external dependencies.

## Installation

Assuming you have a working Rakudo Perl 6 installation with panda
installed you can install from a copy of the source directory:

     panda install .

or remotely:

     panda install XDG::BaseDirectory 

Although I haven't tested, there is no reason that "zef" or some
similarly capable package manager shouldn't work.

## Support

Suggestions/patches are welcomed via github at:

   https://github.com/jonathanstowe/XDG-BaseDirectory/issues

I'm not able to test on a wide variety of platforms so any help there
would be appreciated.

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015, 2016
