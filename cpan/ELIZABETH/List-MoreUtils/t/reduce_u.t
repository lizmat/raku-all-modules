use v6.c;

use List::MoreUtils <reduce_u>;
use Test;

plan 1;

{
    my @exam_results = 0, 2, 4, 6, 5, 3, 0;
    my $pupil = @exam_results.sum;
    my $wa = reduce_u -> $a, $b { $a.defined ?? $a + ++$ * $b / $pupil !! 0 }, @exam_results;
    is $wa, 3.15, "weighted average of exam";
}

# vim: ft=perl6 expandtab sw=4
