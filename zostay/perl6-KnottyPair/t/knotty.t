#!perl6

use v6;

use Test;
use KnottyPair;

my $x = 42;
my $p := 'Y' => $x;
my $f := 'X' =X> $x;

is $p{'Y'}, 42;
is $f{'X'}, 42;

$x++;

is $p{'Y'}, 42;
is $f{'X'}, 43;

my %h = ($f, $p).hash;

is %h{'X'}, 43;
is %h{'Y'}, 42;

$x++;

is $f{'X'}, 44;
is $p{'Y'}, 42;
is %h{'X'}, 43;
is %h{'Y'}, 42;

done-testing;
