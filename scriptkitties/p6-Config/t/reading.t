#! /usr/bin/env perl6

use v6.c;
use Test;
use lib "lib";

plan 3;

use Config;

my $config = Config.new();

throws-like { $config.read("nonexistant-config") }, Config::Exception::FileNotFoundException, "Reading nonexisting file";
throws-like { $config.read("t/test-stub") }, Config::Exception::UnknownTypeException, "Reading file of unknown type";
throws-like { $config.read("t/test-stub", "Config::Parser:NoSuchParserForTest") }, Config::Exception::MissingParserException, "Using non-existing parser";
