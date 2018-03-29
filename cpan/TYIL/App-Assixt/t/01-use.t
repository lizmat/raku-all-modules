#! /usr/bin/env perl6

use v6.c;

use JSON::Fast;
use Test;

my %meta = from-json(slurp("META6.json"));
my @provides = %meta<provides>.keys.grep(* ne "assixt");

plan @provides.elems;

for @provides -> $provide {
	use-ok $provide, "$provide can be used";
}

# vim: ft=perl6 noet
