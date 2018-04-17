use v6.c;

use List::MoreUtils <indexes>;
use Test;

plan 4;

my @x = indexes { $_ > 5 }, (4 .. 9);
is-deeply @x, [2 .. 5], "indexes > 5 ...";
@x = indexes { $_ > 5 }, (1 .. 4);
is-deeply @x, [], 'Got the empty list';

my @o = 0 .. 9;
my @n = map { $_ + 1 }, @o;
@x = indexes { ++$_ > 7 }, @o;
is-deeply @o, @n, "indexes behaves like grep on modified \$_";
is-deeply @x, [7 .. 9], "indexes/modify";

# vim: ft=perl6 expandtab sw=4
