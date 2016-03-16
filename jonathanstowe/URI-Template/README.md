# URI::Template [![Build Status](https://travis-ci.org/jonathanstowe/URI-Template.svg?branch=master)](https://travis-ci.org/jonathanstowe/URI-Template)

Implementation of https://tools.ietf.org/html/rfc6570 for Perl 6

## Synopsis

```

use URI::Template;

my $template = URI::Template.new(template => 'http://foo.com{/foo,bar}');

say $template.process(foo => 'baz', bar => 'quux'); # http://foo.com/baz/quux

```

## Description

This provides an implementation of
[RFC 6570](https://tools.ietf.org/html/rfc6570) which allows for the
definition of a URI through variable expansion.

## Installation

Assuming you have a working perl6 installation you should be able to
install this with *ufo* :

    ufo
    make test
    make install

*ufo* can be installed with *panda* for rakudo:

    panda install ufo

Or you can install directly with "panda":

    # From the source directory
   
    panda install .

    # Remote installation

    panda install URI::Template

Other install mechanisms may be become available in the future.

## Support

However suggestions/patches are welcomed via github at

   https://github.com/jonathanstowe/URI-Template

The test data covers all of the examples given in the RFC and a few others,
if you think the behaviour is incorrect please state the section of the RFC
and provide a failing example with the required variables, template and the
expected output.


## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015, 2016

The testing uses the test data from https://github.com/uri-templates/uritemplate-test
please see the README.md in the t/data/uritemplate-test for the license for that project.


