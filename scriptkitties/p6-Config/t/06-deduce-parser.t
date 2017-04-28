#! /usr/bin/env perl6

use v6.c;
use Test;
use lib "lib";

use Config;

plan 4;

my $config = Config.new;

subtest "Unknown parser type" => {
    plan 1;

    is $config.get-parser-type("config"), "", "Type for plain file without extension";
};

subtest "Check parser type by file extension" => {
    plan 2;

    is $config.get-parser-type("config.yaml"), "yaml", "Should return extension";
    is $config.get-parser-type("config.TOML"), "toml", "Should return lower-cased extension";
};

subtest "Check parser type for edge-cases defined in get-parser-type" => {
    plan 1;

    is $config.get-parser-type("config.yml"), "yaml", "yml --> yaml";
};

subtest "Returns correct fully qualified module name" => {
    plan 4;

    is $config.get-parser("config"), "Config::Parser::", "Empty parser on unknown type";
    is $config.get-parser("config.yaml"), "Config::Parser::yaml", "Extension when available";
    is $config.get-parser("config.TOML"), "Config::Parser::toml", "Lowercased extension";
    is $config.get-parser("config", "Config::Parser::NULL"), "Config::Parser::NULL", "Given string";
};
