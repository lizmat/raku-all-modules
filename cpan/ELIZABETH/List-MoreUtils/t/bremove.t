use v6.c;

use List::MoreUtils <bremove bsearch_remove>;
use Test;

plan 409;

ok &bremove =:= &bsearch_remove, 'is bsearch_remove the same as bremove';

{
    my @a = "foo";
    is bremove( { $_ eq "foo" }, @a), "foo", "could we remove from 1 elem list";    is-deeply @a, [], "are we left with an empty list";

    is bremove( { $_ eq "foo" }, @a), Nil, "did removal fail";
    is-deeply @a, [], "are we still left with an empty list";
}

my @even = map { $_ * 2 }, 1 .. 100;
my @odd  = map { $_ * 2 - 1 }, 1 .. 100;
my @all = 1..200;

my @in = @all;
for @odd -> $v {
    is bremove( { $_ <=> $v }, @in), $v, "did $v get removed";
}
is-deeply @in, @even, "bremove odd elements succeeded";

@in = @all;
for @odd.reverse -> $v {
    is bremove( { $_ <=> $v }, @in), $v, "did $v get removed";
}
is-deeply @in, @even, "bremove odd elements reversely succeeded";

@in = @all;
for @even -> $v {
    is bremove( { $_ <=> $v }, @in), $v, "did $v get removed";
}
is-deeply @in, @odd, "bremove even elements succeeded";

@in = @all;
for @even.reverse -> $v {
    is bremove( { $_ <=> $v }, @in), $v, "did $v get removed";
}
is-deeply @in, @odd, "bremove even elements reversely succeeded";

# vim: ft=perl6 expandtab sw=4
