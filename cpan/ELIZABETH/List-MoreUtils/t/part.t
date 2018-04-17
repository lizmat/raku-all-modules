use v6.c;

use List::MoreUtils <part>;
use Test;

plan 8;

my @list = 1 .. 12;
my $i    = 0;
my @part = part { $i++ % 3 }, @list;
is-deeply @part[0], [1, 4, 7, 10], "  i: part % 3";
is-deeply @part[1], [2, 5, 8, 11], " ii: part % 3";
is-deeply @part[2], [3, 6, 9, 12], "iii: part % 3";

@list[2] = 0;
is @part[2][0], 3, 'Values are not aliases';

@list = 1 .. 12;
@part = part { 3 }, @list;
nok @part[0].defined, "  i: part 3";
nok @part[1].defined, " ii: part 3";
nok @part[2].defined, "iii: part 3";
is-deeply @part[3], [1 .. 12], " iv: part 3";

# vim: ft=perl6 expandtab sw=4
