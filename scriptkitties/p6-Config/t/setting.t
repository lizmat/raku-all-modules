#! /usr/bin/env perl6

use v6.c;
use Test;
use lib "lib";

plan 2;

use Config;

my $config = Config.new();

ok $config.set("a", "test").get("a") eq "test", "Setting simple key";
ok $config.set("b.c", "test").get("b.c") eq "test", "Setting nested key";
