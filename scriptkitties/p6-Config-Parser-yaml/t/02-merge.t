#! /usr/bin/env perl6

use v6.c;
use Test;
use lib "lib";

use Config;

plan 3;

my $config = Config.new();

ok $config.read("t/files/config.yaml"), "Read initial config";
ok $config.read("t/files/merge.yaml"), "Read merge config";

is-deeply $config.get(), {
    a => "a",
    b => {
        c => "c",
        d => "d"
    }
}, "Ensure configurations are merged";
