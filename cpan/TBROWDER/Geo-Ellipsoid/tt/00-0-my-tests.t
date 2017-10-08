#!/usr/local/bin/perl
use Test::More tests => 2;

use Test::Number::Delta relative => 1e-6;
#use Test::Number::Delta within   => 1e-6;
#use Test::Number::Delta;

my $a = 1.000001;
my $b = 1.000002;
delta_ok($a, $b);
delta_within($a, $b, 1e-7);
