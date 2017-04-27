#! /usr/bin/env perl6

use v6.c;
use Test;
use lib "lib";

plan 4;

use Config;

my $config = Config.new();

ok $config.set("a", "test").get("a") eq "test", "Setting simple key";
ok $config.set("b.c", "test").get("b.c") eq "test", "Setting nested key";
ok $config.set(["d"], "test").get("d") eq "test", "Setting simple key using array";
ok $config.set(["e", "f"], "test").get("e.f") eq "test", "Setting nested key using array";
