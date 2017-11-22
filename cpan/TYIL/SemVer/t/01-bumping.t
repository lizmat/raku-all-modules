#! /usr/bin/env perl6

use v6.c;

use Test;

plan 5;

use SemVer;

my SemVer $v .= new;

$v.bump-patch;

is $v.Str, "0.0.1";

$v.bump-minor;

is $v.Str, "0.1.0";

$v.bump-major;

is $v.Str, "1.0.0";

for 1 .. 11 {
	$v.bump-minor;
}

is $v.Str, "1.11.0";

for 1 .. 22 {
	$v.bump-patch;
}

is $v.Str, "1.11.22";
