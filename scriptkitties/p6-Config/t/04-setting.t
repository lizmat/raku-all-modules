#! /usr/bin/env perl6

use v6.c;
use Test;
use lib "lib";

plan 4;

use Config;

my $config = Config.new();

is $config.set("a", "test").get("a"), "test", "Setting simple key";
is $config.set("b.c", "test").get("b.c"), "test", "Setting nested key";
is $config.set(["d"], "test").get("d"), "test", "Setting simple key using array";
is $config.set(["e", "f"], "test").get("e.f"), "test", "Setting nested key using array";
