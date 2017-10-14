#! /usr/bin/env perl6

use v6.c;
use Test;
use lib "lib";

plan 13;

use Config;

my Config $config = Config.new();

$config.read({
    a => "a",
    b => {
        c => "c"
    }
});

is $config.get("a"), "a", "Get simple key";
is $config.get("b.c"), "c", "Get nested key";
is $config.get("nonexistant", "test"), "test", "Get nonexistant key with default";
ok $config.get("nonexistant") === Nil, "Get nonexistant key";

is $config.get(["a"]), "a", "Get simple key by array";
is $config.get(["b", "c"]), "c", "Get nested key by array";
is $config.get(["nonexistant"], "test"), "test", "Get nonexistant key by array with default";
ok $config.get(["nonexistant"]) === Nil, "Get nonexistant key by array";

is $config.<a>, "a", "Get simple key via associative index";
is $config.<b.c>, "c", "Get nested key via associative index";
ok $config.<nonexistant> === Nil, "Get nonexistant key via associative index";

is $config.get(Nil, "test"), "test", "Attempt .get with Nil key with default";
ok $config.get(Nil) === Nil, "Attempt to .get with Nil key";
