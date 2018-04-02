use v6.c;

use Test;

if ?%*ENV<TEST_META> {
    require Test::META <&meta-ok>;
    meta-ok;
} else {
    skip "Skipping Test::META ...";
}

done-testing;
