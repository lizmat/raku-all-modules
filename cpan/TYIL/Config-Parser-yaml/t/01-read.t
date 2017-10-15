#! /usr/bin/env perl6

use v6.c;
use Test;
use lib "lib";

use Config;

plan 5;

my $config = Config.new();

ok $config.read("t/files/config.yaml"), "Read a YAML file";

ok $config.get("a") eq "a", "Get simple key";
ok $config.get("b.c") eq "c", "Get nested key";
ok $config.get("nonexistant") === Nil, "Get nonexistant key";
ok $config.get("nonexistant", "test") === "test", "Get nonexistant key with default";
