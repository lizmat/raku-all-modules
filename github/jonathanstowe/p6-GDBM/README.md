# GDBM

GNU dbm binding for Perl 6

[![Build Status](https://travis-ci.org/jonathanstowe/p6-GDBM.svg?branch=master)](https://travis-ci.org/jonathanstowe/p6-GDBM)

## Synopsis

```perl6

use GDBM;

my $data = GDBM.new('somefile.db');

$data<foo> = 'bar';

say $data<foo>:exists;

$data.close;

# Then in some time later, possibly in another program

$data = GDBM.new('somefile.db');

say $data<foo>;

$data.close;

```

## Description

The [GNU DBM](http://www.gnu.org.ua/software/gdbm/) stores key/value
pairs in a hashed database file. Its implementation allows for keys
and values of arbitrary length (compared to fairly frugal limits on
some earlier implementations.)

This module allows for the data to be transparently managed as if it
were in an normal Associative container such as a Hash.  The only limitation
currently is that both key and value must be strings (or can be meaningfully
stringified,) so e.g. structured data will need to be serialised to some
format that can be represented as a string.  However it can be used for
persistence or caching if this doesn't need to be shared by processes
on different machines.

## Installation

In order to install this you will need to have the GDBM development
packages installed in order to build the wrapper this library requires
on Linux this may be either *libgdbm-dev* or *libgdbm-devel* depending
on the distribution.  For FreeBSD the *database/gdbm* port will install
everything that is required. 

Assuming that you have a working installation of Rakudo Perl 6 you should
be able to install this with *zef* :

     zef install GDBM

     # Or if you have a local checkout of the code

     zef install .

## Support

The gdbm library itself is mature and well tested so it's likely that any
bugs you find are ones I have introduced into the wrapper.  I'd rather
do without the C wrapper but the gdbm api is rather awkward for Perl 6
NativeCall to deal with otherwise.

If you have any suggestions/fixes or actual bugs please report them to
https://github.com/jonathanstowe/p6-GDBM/issues 

## Licence & Copyright

This is free software, please see the [LICENCE](LICENCE) file for details.

© Jonathan Stowe 2017

