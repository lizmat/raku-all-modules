[JSON::Marshal]:   https://github.com/jonathanstowe/JSON-Marshal
[JSON::Unmarshal]: https://github.com/tadzik/JSON-Unmarshal


# JSON::Class

A Role to allow Perl 6 objects  to be constructed and serialised from/to JSON.

## Synopsis

```

    use JSON::Class;

    class Something does JSON::Class {
 
        has Str $.foo;

    }

    my Something $something = Something.from-json('{ "foo" : "stuff" }');

    ...

    my Str $json = $something.to-json(); # -> '{ "foo" : "stuff" }'

```

## Description

This is a simple role that provides methods to instantiate a class from a
JSON string that (hopefully,) represents it, and to serialise an object of
the class to a JSON string.  The JSON created from an instance should
round trip to a new instance with the same values for the "public attributes".
"Private" attributes (that is ones without accessors,) will be ignored for
both serialisation and de-serialisation.  The exact behaviour depends on that
of [JSON::Marshal][] and
[JSON::Unmarshal][] respectively.

The  [JSON::Marshal][] and
[JSON::Unmarshal][] provide traits
for controlling the unmarshalling/marshalling of specific attributes. If these
are required for your application then you will need to use these modules
directly in your code for the time being.

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

    panda install JSON::Class

Other install mechanisms may be become available in the future.

## Support

This should be considered experimental software until such time that
Perl 6 reaches an official release.  However suggestions/patches are
welcomed via github at

   https://github.com/jonathanstowe/JSON-Class

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015

