#! /usr/bin/env perl6

use v6.c;
use Test;

plan 8;

use Config;

my $config = Config.new;

$config.read: %(
	a => "b",
	c => %(
		d => "e",
	),
);

ok $config<a>:exists, "'a' exists";
ok $config<a>:delete, "'a' gets deleted";
nok $config<a>:exists, "'a' no longer exists";
ok $config<c>:exists, "'c' remains untouched";

ok $config.has("c.d"), "'c.d' exists";
ok $config.unset("c.d"), "'c.d' gets deleted";
nok $config.has("c.d"), "'c.d' no longer exists";
ok $config.has("c"), "'c' still exists";
