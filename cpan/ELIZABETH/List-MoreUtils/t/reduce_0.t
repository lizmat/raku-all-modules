use v6.c;

use List::MoreUtils <reduce_0>;
use Test;

plan 1;

{
    my @exam_results = 2, 4, 6, 5, 3, 0;
    my $pupil = @exam_results.sum;
    my $wa = reduce_0 -> $a, $b { $a + ++$ * $b / $pupil }, @exam_results;
    is $wa, 3.15, "weighted average of exam";
}

# vim: ft=perl6 expandtab sw=4
