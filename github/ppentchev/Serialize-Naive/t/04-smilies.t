#!/usr/bin/env perl6

use v6.c;

use Serialize::Naive;
use Test;

plan 1;

class Smilies does Serialize::Naive {
	has Str:D $.path is required;
	has Str $.remote is required;
	has UInt:D $.generation is required;
	has UInt $.tstamp;
	has Rat:D $.ratio is required;
	has Rat $.minimum is required;

	has Str:D @.exclude;
}

my Smilies $cfg .= new(
	:path('path'),
	:remote('remote'),
	:generation(0),
	:ratio(1.5),
	:minimum(-22/7),
);
my $stuff = $cfg.serialize;
is-deeply $stuff, {
	:exclude([]),
	:generation(0),
	:minimum(-22/7),
	:path('path'),
	:ratio(1.5),
	:remote('remote'),
}, 'serialized correctly';
