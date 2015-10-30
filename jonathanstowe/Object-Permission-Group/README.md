# Object::Permission::Group

Object helper for [Object::Permission](https://github.com/jonathanstowe/Object-Permission) using unix groups.

## Synopsis

```
	use Object::Permission::Group; # $*AUTH-USER is derived from $*USER

   # Or:

   Use Object::Permission::Group;

	# Set $*AUTH-USER to one for a specified user
   $*AUTH-USER = Object::Permission::Group.new(user => 'wibble');
```

## Description

This provides a simple implementation of ```Object::Permission::User``` to
be used with [Object::Permission](https://github.com/jonathanstowe/Object-Permission) which derives the permissions for the ```$*AUTH-USER``` from the
users unix group membership.

By default ```$*AUTH-USER``` is initialised based on the value of ```$*USER```
(i.e. the effective user,) but it can be set manually with the permissions
of an arbitrary user (as in the second example above.)


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

    panda install Object::Permission::Group

Other install mechanisms may be become available in the future.

## Support

This should be considered experimental software until such time that
Perl 6 reaches an official release.  However suggestions/patches are
welcomed via github at

   https://github.com/jonathanstowe/Object-Permission-Group

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015

