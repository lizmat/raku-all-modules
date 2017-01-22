# META6

[![Build Status](https://travis-ci.org/jonathanstowe/META6.svg?branch=master)](https://travis-ci.org/jonathanstowe/META6)

Do things with Perl 6 [META files](http://design.perl6.org/S22.html#META6.json)

## Synopsis

The below will generate the  *META.info* for this module.

```
use META6;

my $m = META6.new(   name        => 'META6',
                     description => 'Work with Perl 6 META files',
                     version     => Version.new('0.0.1'),
                     perl        => Version.new('6'),
                     depends     => <JSON::Class>,
                     test-depends   => <Test>,
                     tags        => <devel meta utils>,
                     authors     => ['Jonathan Stowe <jns+git@gellyfish.co.uk>'],
                     auth        => 'github:jonathanstowe',
                     source-url  => 'git://github.com/jonathanstowe/META6.git',
                     support     => META6::Support.new(
                        source => 'git://github.com/jonathanstowe/META6.git'
                     ),
                     provides => {
                        META6 => 'lib/META6.pm',
                     },
                     license     => 'Artistic',
                     production  => False,

                 );

print $m.to-json;

my $m = META6.new('./META6.json');
$m<version description> = v0.0.2, 'Work with Perl 6 META files even better';
spurt('./META6.json', $m.to-json);
```
## Description

This provides a representation of the Perl 6 [META
files](http://design.perl6.org/S22.html#META6.json) specification -
the META file data can be read, created , parsed and written in a manner
that is conformant with the specification.

Where they are known about it also makes allowance for "customary"
usage in existing software (such as installers and so forth.)

The intent of this is allow the generation and testing of META files for
module authors, so it can provide meta-information whether the attributes
are mandatory as per the spec and where known the places that "customary"
attributes are used,


## Installation

Assuming you have a working Rakudo Perl 6 installation you should be able to
install this with *panda* :

    # From the source directory
   
    panda install .

    # Remote installation

    panda install META6

This should work equally well with *zef* but I have not tested it.

## Support

Suggestions/patches are welcomed via github at

https://github.com/jonathanstowe/META6

I'm particulary interested in knowing about "customary" (i.e. non-spec)
fields that are being used in the wild and in what software so I can
add them if necessary.

## Licence

Please see the [LICENCE](LICENCE) file in the distribution

© Jonathan Stowe 2015, 2016, 2017

