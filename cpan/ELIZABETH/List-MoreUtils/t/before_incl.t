use v6.c;

use List::MoreUtils <before_incl>;
use Test;

plan 3;

my @x = before_incl * %% 5, (1 .. 9);
is-deeply @x, [1,2,3,4,5], "before_incl 5";

@x = before_incl { /foo/ }, <bar baz>;
is-deeply @x, [<bar baz>], 'Got the whole list';

@x = before_incl *.starts-with("b"), <alpha bar baz foo>;
is-deeply @x, [<alpha bar>], "before_incl /^b/";

# vim: ft=perl6 expandtab sw=4
