use v6.c;

use List::MoreUtils <lower_bound>;
use Test;

plan 227;

my @list =
  1, 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 6, 7, 7, 7,
  8, 8, 9, 9, 9, 9, 9, 11, 13, 13, 13, 17
;
is lower_bound( { $_ <=>  0 }, @list),  0, "lower bound 0";
is lower_bound( { $_ <=>  1 }, @list),  0, "lower bound 1";
is lower_bound( { $_ <=>  2 }, @list),  2, "lower bound 2";
is lower_bound( { $_ <=>  4 }, @list), 10, "lower bound 4";
is lower_bound( { $_ <=> 19 }, @list), +@list, "lower bound 19";

my @in = @list = 1 .. 100;
for ^@in -> $i {
    my $j = @in[$i] - 1;
    is lower_bound( { $_ - $j }, @list), $i - 1 max 0, "placed $j";
    is lower_bound( { $_ - @in[$i] }, @list), $i, "found @in[$i]";
}

my @lout = @in[0] - 11 .. @in[0] - 1;
for @lout -> $elem {
    is lower_bound( { $_ - $elem }, @list), 0, "put smaller $elem in front";
}

my @uout = @in[*-1] + 1 .. @in[*-1] + 11;
for @uout -> $elem {
    is lower_bound( { $_ - $elem }, @list), +@list, "put bigger $elem at end";
}

# vim: ft=perl6 expandtab sw=4
