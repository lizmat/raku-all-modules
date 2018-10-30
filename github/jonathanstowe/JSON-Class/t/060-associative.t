#!/usr/bin/env perl6

use v6.c;

use Test;

use JSON::Class;

class C is JSON::Class {
	has Str %.bla{subset :: of Str where any("ble", "blob")}
};

my $res;
todo "Only recently fixed in rakudo", 2;
lives-ok {
    $res = C.from-json('{"bla": {"ble": "bli"}}');
    is $res.bla<ble>, 'bli', "and get the right value";
}, "from-json with shaped associative works";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
