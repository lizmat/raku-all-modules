use v6.c;

use List::MoreUtils <after_incl>;
use Test;

plan 3;

my @x = after_incl * %% 5, (1 .. 9);
is-deeply @x, [5, 6, 7, 8, 9], "after_incl 5";

@x = after_incl { /foo/ }, <bar baz>;
is-deeply @x, [], 'Got the empty list';

@x = after_incl *.starts-with("b"), <alpha bar baz foo>;
is-deeply @x, [<bar baz foo>], "after_incl /^b/";

# vim: ft=perl6 expandtab sw=4
