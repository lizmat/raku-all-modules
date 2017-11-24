#! /usr/bin/env perl6

use v6.c;

use Test;

plan 5;

use SemVer;

my SemVer $v .= new;

$v.bump-patch;

is $v, "0.0.1";

$v.bump-minor;

is $v, "0.1.0";

$v.bump-major;

is $v, "1.0.0";

for 1 .. 11 {
	$v.bump-minor;
}

is $v, "1.11.0";

for 1 .. 22 {
	$v.bump-patch;
}

is $v, "1.11.22";
