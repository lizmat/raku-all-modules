# Staticish

Make a singleton class that wraps the methods so they appear like class methods

## Description

This provides a mechanism whereby a class can be treated as a "singleton" and all
of its methods wrapped such that if they are called as "class" or "static" methods
they will actually be called on the single instance.  It does this by applying a
role to the class itself which provides a constructor "new()"  that will always
return the same instance of the object, and by applying a role to the classes
Meta class which over-rides the "add_method" method in order to wrap the programmer
supplied methods such that if the method is called on the type object (i.e. as a 
class method) then the single instance will be obtained and the method will be
called with that as the invocant.

This might be useful for a class such as a configuration parser or logger where
a single set of parameters will be used globally within an application and it
doesn't make sense to pass a single object around.

It may not deal with every possible use case properly, but it largely does what
I need it to.  Suggestions, patches etc are welcome.

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

    panda install Staticish

Other install mechanisms may be become available in the future.

## Support

This should be considered experimental software until such time that
Perl 6 reaches an official release.  However suggestions/patches are
welcomed via github at

https://github.com/jonathanstowe/Staticish

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015
