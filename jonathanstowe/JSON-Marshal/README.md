# JSON::Marshal

Make JSON from an Object (the opposite of JSON::Unmarshal)

## Synopsis

```
   use JSON::Marshal;

    class SomeClass {
      has Str $.string;
      has Int $.int;
      has Version $.version is marshalled-by('Str');
    }

    my $object = SomeClass.new(string => "string", int => 42, version => Version.new("0.0.1"));


    my Str $json = marshal($object); # -> "{ "string" : "string", "int" : 42, "version" : "0.0.1" }'


```

## Description

This provides a single exported subroutine to create a JSON representation
of an object.  It should round trip back into an object of the same class
using [JSON::Unmarshal](https://github.com/tadzik/JSON-Unmarshal).

It only outputs the "public" attributes (that is those with accessors
created by declaring them with the '.' twigil. Attributes without acccessors
are ignored.

To allow a finer degree of control of how an attribute is marshalled an
attribute trait C<is marshalled-by> is provided, this can take either
a Code object (an anonymous subroutine,) which should take as an argument
the value to be marshalled and should return a value that can be completely
represented as JSON, that is to say a string, number or boolean or a Hash
or Array who's values are those things. Alternatively the name of a method
that will be called on the value, the return value being constrained as
above.

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

    panda install JSON::Marshal

Other install mechanisms may be become available in the future.

## Support

This should be considered experimental software until such time that
Perl 6 reaches an official release.  However suggestions/patches are
welcomed via github at

   https://github.com/jonathanstowe/JSON-Marshal

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015

