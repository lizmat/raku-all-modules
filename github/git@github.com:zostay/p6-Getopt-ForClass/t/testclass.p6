#!/usr/bin/env perl6
use v6;

use lib 'lib';
use Getopt::ForClass;

class TestClass {
    has $.foo;
    has $.bar;

    submethod BUILD(:$!foo, Int :$!bar) { }

    method command-one(Int $x, :$y) { say 'one' }
    method command-two(:$x, Int :$y) { say 'two' }
    method command-three(Str $x, Str $y) { say 'three' }
    method not-command($x) { say 'four' }
}

my &MAIN = build-main-for-class(
    class   => TestClass,
    methods => rx/^ "command-" /,
);
