#! /usr/bin/env perl6

use v6.c;
use Test;
use lib "lib";

plan 4;

use Config;

my $config = Config.new();

throws-like { $config.read("t/files/none") }, Config::Exception::FileNotFoundException, "Reading nonexisting file";
throws-like { $config.read("t/files/config", "Config::Parser:NoSuchParserForTest") }, Config::Exception::MissingParserException, "Using non-existing parser";

my $hash = {
    "a" => "a",
    "b" => {
        "c" => "test"
    }
};

$config.read($hash);

is-deeply $config.get(), $hash, "Correctly sets hash";

$config.read({
    "b" => {
        "d" => "another"
    }
});

is-deeply $config.get(), {
    "a" => "a",
    "b" => {
        "c" => "test",
        "d" => "another"
    }
}, "Correctly merges new hash into existing config";
