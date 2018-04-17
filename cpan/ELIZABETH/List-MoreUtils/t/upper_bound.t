use v6.c;

use List::MoreUtils <upper_bound>;
use Test;

plan 227;

my @list =
  1, 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 6, 7, 7, 7,
  8, 8, 9, 9, 9, 9, 9, 11, 13, 13, 13, 17
;
is upper_bound( { $_ <=>  0 }, @list),  0, "upper bound 0";
is upper_bound( { $_ <=>  1 }, @list),  2, "upper bound 1";
is upper_bound( { $_ <=>  2 }, @list),  4, "upper bound 2";
is upper_bound( { $_ <=>  4 }, @list), 14, "upper bound 4";
is upper_bound( { $_ <=> 19 }, @list), +@list, "upper bound 19";

my @in = @list = 1 .. 100;
for ^@in -> $i {
    my $j = @in[$i] - 1;
    is upper_bound( { $_ - $j }, @list), $i, "placed $j";
    is upper_bound( { $_ - @in[$i] }, @list), $i + 1, "found @in[$i]";
}

my @lout = @in[0] - 11 .. @in[0] - 1;
for @lout -> $elem {
    is upper_bound( { $_ - $elem }, @list), 0, "put smaller $elem in front";
}

my @uout = @in[*-1] + 1 .. @in[*-1] + 11;
for @uout -> $elem {
    is upper_bound( { $_ - $elem }, @list), +@list, "put bigger $elem at end";
}

# vim: ft=perl6 expandtab sw=4
