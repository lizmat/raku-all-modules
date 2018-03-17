#! /usr/bin/env perl6

use v6.c;

use Test;
use JSON::Fast;

my %provides = from-json(slurp "META6.json")<provides>;

plan %provides.elems;

for %provides.keys -> $module {
	use-ok $module;
}

# vim: ft=perl6 noet
