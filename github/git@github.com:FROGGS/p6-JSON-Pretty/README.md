[![Build Status](https://travis-ci.org/FROGGS/p6-JSON-Pretty.svg?branch=master)](https://travis-ci.org/FROGGS/p6-JSON-Pretty)

A simple Perl 6 module for serializing and deserializing JSON.
This is actually a fork of JSON::Tiny [1], with the difference that produced
JSON is indented. Its goal is to be readable especially for debugging
purposes. This module exposes the same API as JSON::Tiny, so all you have
to do to switch between both is to change your "use" statement.

All files (unless noted otherwise) can be used, modified and redistributed
under the terms of the Artistic License Version 2. Examples (in the
documentation, in tests or distributed as separate files) can be considered
public domain.

To build and test this module run:

    panda install JSON::Pretty

Credits
    Moritz Lenz <moritz@faui2k3.org>
    Johan Viklund
    Jonathan Worthington
    Tobias Leich

[1] https://github.com/moritz/json
