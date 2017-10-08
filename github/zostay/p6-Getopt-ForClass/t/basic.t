#!/usr/bin/env perl6
use v6;

use Getopt::ForClass;
use Test;

class TestClass {
    has $.foo;
    has $.bar;

    submethod BUILD(:$!foo, Int :$!bar) { }

    method command-one(Int $x, :$y) { 1 }
    method command-two(:$x, Int :$y) { 2 }
    method command-three(Str $x, Str $y) { 3 }
    method not-command($x) { 4 }
}

my &test-main = build-main-for-class(
    class   => TestClass,
    methods => rx/^ "command-" /,
);

isa-ok &test-main, Routine, 'got a routine';

is &test-main.candidates.elems, 3, 'should have three candidates';
is test-main('command-one', 10), 1, 'ran command-one';
is test-main('command-two'), 2, 'ran command-two';
is test-main('command-three', 'x', 'y'), 3, 'ran command-three';
dies-ok { test-main('not-command', 'x') }, 'cannot run not-command';

done-testing;
