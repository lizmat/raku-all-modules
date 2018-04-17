use v6.c;

use List::MoreUtils <natatime>;
use Test;

plan 2;

my @x = 'a' .. 'g';
my &it = natatime 3, @x;
my @r;
while it() -> @vals {
    @r.push: "@vals[]";
}
is-deeply @r, ['a b c', 'd e f', 'g'],"natatime with letters";

my @a = 1 .. 1000;
&it = natatime 1, @a;
@r = ();
while it() -> @vals {
    @r.append(@vals);
}
is-deeply @r, @a, "natatime with numbers";

# vim: ft=perl6 expandtab sw=4
