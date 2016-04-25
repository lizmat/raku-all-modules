#!perl6

use v6;

use Test;
use EuclideanRhythm;

my $slots = 16;

for (0 .. $slots) -> $fills {
    my $obj;
    lives-ok { $obj = EuclideanRhythm.new(:$slots, :$fills) }, "got obj with $fills/$slots";
    is $obj.list[^16].grep({ so $_ }).elems, $fills, "got the $fills we expected";
    is-deeply $obj.list[^16], $obj.list[16 .. 31], "and the second set is the same as the first etc";
    is $obj.once.elems, 16, "once gets the right number of elements";
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
