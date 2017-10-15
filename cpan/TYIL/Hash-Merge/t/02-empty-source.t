#! /usr/bin/env perl6

use v6.c;
use lib 'lib';
use Test;

plan 3;

use Hash::Merge;

my Hash $hash = {
    a => "a",
    b => {
        c => "c"
    }
};

my Hash $empty = {};

$empty.merge($hash);

is-deeply $empty, $hash, "Merge into empty hash";

my Hash $nil;


throws-like $nil.merge($hash), Exception, "Merge into uninitialized hash";
is-deeply $nil.merge($hash), $hash, "Returns supplied hash if it throws";
