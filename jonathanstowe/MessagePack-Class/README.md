# MessagePack::Class

Serialize/Deserialize Perl 6 classes to/from MessagePack blobs

[![Build Status](https://travis-ci.org/jonathanstowe/MessagePack-Class.svg?branch=master)](https://travis-ci.org/jonathanstowe/MessagePack-Class)


## Synopsis

```perl6

use MessagePack::Class;

class MyClass does MessagePack::Class {
	has Str $.some-data;
}

my Blob $pack = MyClass.new(some-data => "whatever").to-messagepack;

# Then send $pack over the network, write it to a file or something

my MyClass $obj = MyClass.from-messagepack($pack);


```

## Description

[MessagePack](http://msgpack.org/) is a binary serialization format that
is particularly efficient for transmission over a network or file storage.

This module provides a role that allows for the direct serialization of
a Perl 6 object to a MessagePack binary blob and the deserialization of
that blob back to a Perl 6 object of the same type with the same attribute
values.

Under the hood it uses [Data::MessagePack](https://github.com/pierre-vigier/Perl6-Data-MessagePack)
to serialize and deserialize data structures representing the object in a very
similar manner to [JSON::Marshal](https://github.com/jonathanstowe/JSON-Marshal) and
[JSON::Unmarshal](https://github.com/tadzik/JSON-Unmarshal) (infact it borrows some
of the internal code of both of those to construct a suitable data structure.)

For a simple case this may work with your class unchanged apart from the addition of
the role composition, however for types that may not be properly constructed from
their public attributes there are provided the attribute traits ```packed-by``` and
```unpacked-by``` which allow you to provide either a subroutine or a method name
that will work with a representation that will round-trip properly.

A named method supplied to ```packed-by``` will be called on the object to be serialized
without any arguments and should return a value suitable for serialization, and a method
supplied to ```unpacked-by``` will be called on the type object with the value to be
deserialized as a single positional argument and should return an object of the type.


So for instance if one had a class with an attribute of type Version one might do:

```
class TraitTest does MessagePack::Class {
    has Version $.version is packed-by('Str') is unpacked-by('new');
}
```

Where the ```Str``` method returns a string that is suitable to be passed to ```new```
to create a new Version  object.

If a subroutine (or other Callable object) is passed to the traits then it should take
a single argument and return a value suitable for serialization (for ```packed-by```) or
an object of the appropriate type (for ```unpacked-by```) so the above example might
become:

```
class TraitTest does MessagePack::Class {
    has Version $.version is packed-by(-> Version $v { $v.Str }) is unpacked-by(-> Str $v { Version.new($v)});
}
```

You can of course make the subroutines as complex as is required for your types.

If you need your data to be interoperable with software written in another language
you may need to adjust the serialization accordingly to match the types available
in that language.

## Installation

Assuming you have a working Rakudo Perl 6 installation the you should be able
to install this with ```panda``` :

    panda install MessagePack::CLass

    # or from a local check-out:

    panda install .

Or with ```zef```:

    zef install MessagePack::Class

    # or from a local check-out:

    zef install .

Though I can't see any reason this shouldn't work with any other installer that
may come along in the future.

## Support

If you find a problem with this module or have a suggestion please report at
https://github.com/jonathanstowe/MessagePack-Class/issues - though I always
prefer a pull request with tests if you can do that.

## Licence and Copyright

This is free software. Please see the [LICENCE](LICENCE) file in this repository.

© Jonathan Stowe 2017
