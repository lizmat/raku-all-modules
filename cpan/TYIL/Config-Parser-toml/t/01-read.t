#! /usr/bin/env perl6

use v6.c;
use Test;
use lib "lib";

use Config;
use Config::Parser::toml;

plan 4;

my $config = Config.new();

ok $config.read("t/files/config.toml"), "File reading throws no error";

subtest "Contents match" => {
    plan 2;

    is $config.get("header.a"), "a", "a = a";
    is $config.get("header.b"), "b", "b = b";
};

ok $config.read("t/files/merge.toml"), "File merging throws no error";

subtest "Contents match after merging" => {
    plan 4;

    is $config.get("header.a"), "a", "a = a";
    is $config.get("header.b"), "b", "b = b";
    is $config.get("header.c"), "c", "c = c";

    is $config.get("merge-header.a"), "a", "a = a";
};
