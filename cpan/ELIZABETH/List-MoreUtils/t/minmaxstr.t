use v6.c;

use List::MoreUtils <minmaxstr>;
use Test;

plan 3;

my @list = reverse "AA".."ZZ";
is-deeply minmaxstr(@list), ("AA","ZZ"), "get minmaxstr of reversed range";

@list.push: "ZZ Top";
is-deeply minmaxstr(@list), ("AA","ZZ Top"), "even number of elements";

is-deeply minmaxstr(("foo",)), ("foo","foo"), "single element list";

# vim: ft=perl6 expandtab sw=4
