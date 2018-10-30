# perl6-Fcntl

Fcntl implementation (mimicking Perl 5)

# Build Status

[![Build Status](https://travis-ci.org/manchicken/perl6-Fcntl.svg?branch=master)](https://travis-ci.org/manchicken/perl6-Fcntl)

# Approach

For this module, I'm trying to give you a module which has the native
definitions for constants for a given OS, generated from `C` headers but
available in a pure Perl 6 module. In order to do this, I've written a very
small `C` program which appends Perl 6 code to a template, and then that's
what you use. I've also written a small test program that allows me to verify
the values are what C thinks they should be when I send them back in.

For more details, read the POD.
