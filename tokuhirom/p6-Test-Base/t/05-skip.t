use v6;
use Test;

use Test::Base;

subtest {
    my @blocks = blocks(q:to/EOD/);
    === hoh
    --- input

    === gah
    --- SKIP
    --- input

    === heh
    --- input

    EOD

    is @blocks».title.join(','), 'hoh,heh';
}, 'no title';

done-testing;
