#!/usr/bin/env perl6

use v6;

use Test;

use Algorithm::Evolutionary::Simple;

my $length = 32;

my @χ= random-chromosome( $length );
cmp-ok( royal-road( @χ ), ">=", 0, "Basic testing Royal Road");

@χ = ( True, True, True, True, False, False, False, False, True, False, True, False );
is( royal-road( @χ ), 2, "Testing Royal Road");


done-testing;
