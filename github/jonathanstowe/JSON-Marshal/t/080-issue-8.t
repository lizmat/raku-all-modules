#!/usr/bin/env perl6

use v6.c;

use Test;

use JSON::Marshal;
use JSON::Fast;

class C {

}

class D {
    has Str $.gh;
}

my @tests = (
    {
        description => "class with no attributes",
        type_object => C,
    },
    {
        description => "class with attributes",
        type_object => D,
    },
    {
        description => "Hash type object",
        type_object => Hash,
    },
    {
        description => "Array type object",
        type_object => Array,
    },
);

for @tests -> $test {
    subtest {
        my $out;
        lives-ok { $out = marshal($test<type_object>) }, "marshal type-object";
        my $in = from-json($out);
        nok $in.defined, "roundtripped value not defined";
        ok $in ~~ Any, "it's an Any";
        ok $in !~~ Hash, "and it's not a hash";
        

    }, $test<description>;
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
