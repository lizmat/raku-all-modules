#! /usr/bin/env perl6

use v6.c;
use Test;
use lib "lib";

use Config;
use Config::Parser::toml;
use File::Temp;

plan 4;

my $config = Config.new();

$config.read({
    first => {
        a => "a",
        b => "b"
    },
    second => {
        a => "a",
        c => "c"
    }
});

my ($filename, $fh) = tempfile;

ok $config.write($filename, "Config::Parser::toml"), "Write succeeded";

is slurp("t/files/write.toml"), slurp($filename), "Written config is correct";

ok $config.write($filename, "Config::Parser::toml"), "Write over non-empty file";

is slurp("t/files/write.toml"), slurp($filename), "Written config is still correct";
