# -*- mode: perl6; -*-
use v6;

use JSON::Fast;
use Test;

plan 2;


my @hoge = 1, 2, 3;

my $json = to-json( @hoge );

is "[\n  1,\n  2,\n  3\n]", $json;

my $piyo    = from-json( $json );

is (1, 2, 3), $piyo;

done-testing;
