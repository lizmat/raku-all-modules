# AccessorFacade

A Perl 6 method trait to turn indivdual get/set subroutines into a single
read/write object attribute.

## Description

This module was initially designed to reduce the boiler plate code in
a native library binding that became something like:

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

That is the library API provides a sort of "object oriented" mechanism to
set and get attributes on an opaque object instance that was returned
by another "constructor" function. Because the object is an opaque
CPointer it can only have subroutines and methods and not private data or
attributes. The intent of the code is to provide fake "attributes" with
rw methods (which is similar to how public rw attributes are provided.)

The above code will be reduced with the use of AccessorFacade to:

    class Shout is repr('CPointer') {

        sub shout_set_host(Shout, Str) returns int32 is native('libshout') { * } 
        sub shout_get_host(Shout) returns Str is native('libshout') { * }

        method host() is rw is accessor-facade(&shout_set_host, &shout_get_host) { }

        ...
    }

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

    panda install AccessorFacade

Other install mechanisms may be become available in the future.

## Support

This should be considered experimental software until such time that
Perl 6 reaches an official release.  However suggestions/patches are
welcomed via github at:

https://github.com/jonathanstowe/AccessorFacade

It may use features and behaviour of Perl 6 that aren't present in even
slightly older builds (and which are anticipated to be in a release,)
please check with a new build before reporting a bug.

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015
