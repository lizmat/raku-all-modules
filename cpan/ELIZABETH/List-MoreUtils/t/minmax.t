use v6.c;

use List::MoreUtils <minmax>;
use Test;

plan 4;

my @list = reverse 0 .. 10000;
is-deeply minmax(@list), (0,10000), "get minmax of reversed range";

@list.push: 10001;
is-deeply minmax(@list), (0,10001), "even number of elements";

@list = 0, -1.1, 3.14, 1 / 7, 10000, -10 / 3;
is-deeply minmax(@list), (-10/3,10000), "some rats";

is-deeply minmax((-1,)), (-1,-1), "single element list";

# vim: ft=perl6 expandtab sw=4
