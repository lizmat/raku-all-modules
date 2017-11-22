#! /usr/bin/env perl6

use v6.c;

use Test;

use SemVer;

my SemVer $v;

plan 3;

is $v.new.Str, "0.0.0", "No arguments";
is $v.new(1, 2, 3).Str, "1.2.3", "(1, 2, 3)";
is $v.new("2.3.4").Str, "2.3.4", '"2.3.4"';
