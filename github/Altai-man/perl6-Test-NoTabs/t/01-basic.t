use v6;

use Test;
use Test::NoTabs;

plan 1;

spurt "test-without-tabs", "    good data\n    new data\n   new data";

notabs-ok("test-without-tabs");

"test-without-tabs".IO.unlink;
