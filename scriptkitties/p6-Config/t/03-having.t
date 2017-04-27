#! /usr/bin/env perl6

use v6.c;
use Test;
use lib "lib";

plan 4;

use Config;

my $config = Config.new();

$config.read({
    a => "a",
    b => {
        c => "c"
    }
});

ok $config.has("a"), "Check existence of simple key";
ok $config.has("b.c"), "Check existence of nested key";
ok $config.has(["a"]), "Check existence of simple key using array";
ok $config.has(["b", "c"]), "Check existence of nested key using array";
