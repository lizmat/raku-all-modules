# AccessorFacade

A Perl 6 method trait to turn indivdual get/set subroutines into a single
read/write object attribute.

## Description

This module was initially designed to reduce the boiler plate code in
a native library binding that became something like:

```perl6

    class Shout is repr('CPointer') {

        sub shout_set_host(Shout, Str) returns int32 is native('libshout') { * }
        sub shout_get_host(Shout) returns Str is native('libshout') { * }

        method host() is rw {
            Proxy.new(
                FETCH => sub ($) {
                    shout_get_host(self);
                },
                STORE   =>  sub ($, $host is copy ) {
                    explicitly-manage($host);
                    shout_set_host(self, $host);
                }
            );
        }

        ...

    }

```

That is the library API provides a sort of "object oriented" mechanism to
set and get attributes on an opaque object instance that was returned
by another "constructor" function. Because the object is an opaque
CPointer it can only have subroutines and methods and not private data or
attributes. The intent of the code is to provide fake "attributes" with
rw methods (which is similar to how public rw attributes are provided.)

The above code will be reduced with the use of AccessorFacade to:

```perl6

    class Shout is repr('CPointer') {

        sub shout_set_host(Shout, Str) returns int32 is native('libshout') { * } 
        sub shout_get_host(Shout) returns Str is native('libshout') { * }

        method host() is rw is accessor-facade(&shout_get_host, &shout_set_host) { }

        ...
    }
```

The named argument style is also support so the method could be written as:

```perl6
    method host() is rw is accessor-facade(getter => &shout_get_host, setter => &shout_set_host) { }
```

if that proves more suitable.

(The call to explicitly manage is omitted for simplicity but how this is
achieved is described in the documentation.)  Libshout has a significant
number of these get/set pairs so there is a reduction of typing, copy
and paste and hopefully programmer error.

Whilst this was designed primarily to work with a fixed native API, it
is possible that it could be used to provide an OO facade to a plain
perl procedural library. The only requirement that there is a getter
subroutine that accepts an object as its first argument and returns the
attribute value and a setter subroutine that accepts the object and the
value to be set (it may return a value to indicate success - how this
is handled is descibed in the documentation.)


## Installation

Assuming you have a working Rakudo Perl 6 installation you should be able to
install this with *panda* :

    # From the source directory
   
    panda install .

    # Remote installation

    panda install AccessorFacade

It should work equally well with *zef* but I may not have tested it.

## Support

Suggestions/patches are welcomed via github at:

https://github.com/jonathanstowe/AccessorFacade

## Licence

This is free software.

Please see the [LICENCE](LICENCE) file in the distribution

© Jonathan Stowe 2015, 2016, 2017
