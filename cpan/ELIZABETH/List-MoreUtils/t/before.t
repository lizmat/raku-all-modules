use v6.c;

use List::MoreUtils <before>;
use Test;

plan 3;

my @x = before * %% 5, (1 .. 9);
is-deeply @x, [1,2,3,4], "before 5";

@x = before { /foo/ }, <bar baz>;
is-deeply @x, [<bar baz>], 'Got the whole list';

@x = before *.starts-with("b"), <alpha bar baz foo>;
is-deeply @x, [<alpha>], "before /^b/";

# vim: ft=perl6 expandtab sw=4
