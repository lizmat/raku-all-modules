use v6;

use Test;
plan 3;

constant AUTHOR = ?%*ENV<TEST_AUTHOR>; 

if AUTHOR {
    require Test::Coverage <&meta-ok &subtest_anypod_ok &subtest_coverage_ok>;
    ok 1, "At least loads";
    subtest_anypod_ok('META.info');
    subtest_coverage_ok('META.info');
    done-testing;
}
else {
    skip-rest "Skipping author test";
    exit;
}
