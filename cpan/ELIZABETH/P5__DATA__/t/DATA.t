use v6.c;
use Test;
use P5__DATA__;

plan 4;

is DATA.get, "This is line 1\n", "did we get line 1";
is DATA.get, "This is line 2\n", "did we get line 2";
is DATA.get, "\n", "did we get the empty line";
is DATA.get, "# vim: ft=perl6 expandtab sw=4\n", "did we get the last line";

__DATA__
This is line 1
This is line 2

# vim: ft=perl6 expandtab sw=4
