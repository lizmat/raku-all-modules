#! /usr/bin/env perl6

use v6;

use Config::Parser::NULL;
use Config;
use Test;

plan 1;

my Config $c .= new.read: %(
	"a" => False,
	"b" => False,
	"c" => %(
		"a" => False,
		"b" => False,
	),
);

my @keys = < a b c.a c.b >;

is $c.keys, @keys, ".keys returns a list of all keys";

# vim: ft=perl6 noet
