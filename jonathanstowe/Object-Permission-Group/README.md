# Object::Permission::Group

Object helper for [Object::Permission](https://github.com/jonathanstowe/Object-Permission) using unix groups.

## Synopsis

```perl6
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

Assuming you have a working Rakudo Perl 6 installation you should be able to
install this with *panda* :

    # From the source directory
   
    panda install .

    # Remote installation

    panda install Object::Permission::Group

There is no reason to believe this shouldn't work with *zef* as well.

## Support

Suggestions/patches are welcomed via github at:

https://github.com/jonathanstowe/Object-Permission-Group

## Licence

This is free software.

Please see the [LICENCE](LICENCE) file in the distribution

© Jonathan Stowe 2015, 2016, 2017

