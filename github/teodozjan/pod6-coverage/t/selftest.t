use v6;

use Test;
use Test::Coverage;
plan 3;

ok 1, "At least loads";
subtest_anypod_ok('META6.json');
subtest_coverage_ok('META6.json');
