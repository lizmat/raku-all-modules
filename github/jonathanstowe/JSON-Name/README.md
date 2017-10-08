# JSON::Name

Provide a trait (and Attribute role) for JSON Marshal/Unmarshal where
the JSON names aren't Perl identifiers

## Synopsis

```perl6
use JSON::Name;

class MyClass {
	# The attribute meta object will have the role JSON::Name::NamedAttribute
   # applied and "666.evil.name" will be stored in it's json-name attribute
   has $.nice-name is json-name('666.evil.name');

}

```

## Description

This is released as a dependency of
[JSON::Marshal](https://github.com/jonathanstowe/JSON-Marshal) and
[JSON::Unmarshal](https://github.com/tadzik/JSON-Unmarshal) in order to
save duplication, it is intended to store a separate JSON name for an
attribute where the name of the JSON attribute might be changed, either
for aesthetic reasons or the name is not a valid Perl identifier. It will
of course also be needed in classes thar are going to use JSON::Marshal
or JSON::Unmarshal for serialisation/de-serialisation.

Of course it could be used in other modules for a similar purpose.

## Installation

Assuming you have a working Rakudo Perl 6 installation you should be able to
install this with *zef* :

    # From the source directory
   
    zef install .

    # Remote installation

    zef install JSON::Name


## Support

Suggestions/patches are welcomed via github at

https://github.com/jonathanstowe/JSON-Name

## Licence

This is free software.

Please see the [LICENCE](LICENCE) file in the distribution

© Jonathan Stowe 2015, 2016, 2017
