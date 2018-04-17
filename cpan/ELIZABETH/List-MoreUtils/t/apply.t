use v6.c;

use List::MoreUtils <apply>;
use Test;

plan 5;

my @list = 0 .. 9;
my @list1 = apply { $_++ }, @list;
is-deeply @list,  [0 .. 9],  "original numbers untouched";
is-deeply @list1, [1 .. 10], "returned numbers increased";

@list = (" foo ", " bar ", "     ", "foobar");
@list1 = apply { s:g/^ \s+ | \s+ $// }, @list;
is-deeply @list,  [" foo ", " bar ", "     ", "foobar"],
  "original strings untouched";
is-deeply @list1, ["foo",   "bar",   "",      "foobar"],
  "returned strings stripped";

my $item = apply { s:g/^ \s+ | \s+ $// }, @list, :scalar;
is $item, "foobar", ":scalar returns last item";

# vim: ft=perl6 expandtab sw=4
