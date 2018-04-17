use v6.c;

use List::MoreUtils <bsearchidx bsearch_index>;
use Test;

plan 1023;

ok &bsearchidx =:= &bsearch_index, 'is bsearch_index the same as bsearchidx';

my @list = my @in = 1 .. 1000;
for @in -> $elem {
    is bsearchidx( { $_ - $elem }, @list), $elem - 1, "did we find $elem";
}

my @out = |(-10 .. 0), |(1001 .. 1011);
for @out -> $elem {
    is bsearchidx( { $_ - $elem }, @list), -1, "did we fail to find $elem";
}

# vim: ft=perl6 expandtab sw=4
