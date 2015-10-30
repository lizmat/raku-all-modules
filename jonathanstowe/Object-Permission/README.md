# Object-Permission

Experimental method (and public attribute accessor,) level authorisation
for Perl 6 objects.

## Synopsis

	use Object::Permission;

	class Foo {
		has $.baz is authorised-by('baz');

		method bar() is authorised-by('barbar') {
			...
		}
	}
	
	# Object::Permission::User is a role, just use type pun
	$*AUTH-USER = Object::Permission::User.new(permissions => <barbar zub>);

	my $foo = Foo.new;

	$foo.bar();   # Executes okay
	say $foo.baz; # Throws X::NotAuthorised

## Description

This is an experimental module to provide a rudimentary authorisation
mechanism for classes whereby selected methods or public attribute
accessors can require a named permission to execute, the permissions
associated with the dynamic variable ```$*AUTH-USER``` being checked
at invocation and an exception being thrown if the User object does not
have the required permission.

The intent is that ```$*AUTH-USER``` is initialised with an object
of some class that does the role ```Object::Permission::User``` which
populates the permissions as per the application logic.

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

    panda install Object::Permission

Other install mechanisms may be become available in the future.

## Support

This should be considered experimental software until such time that
Perl 6 reaches an official release.  However suggestions/patches are
welcomed via github at

   https://github.com/jonathanstowe/Object-Permission

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015

