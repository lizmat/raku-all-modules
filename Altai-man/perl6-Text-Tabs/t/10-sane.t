use v6;

use Test;
use lib 'lib';
use Text::Tabs;

plan 3;

ok expand(["		"], 4)[0] eq "        ", 'two tabs were converted to 8 spaces';
ok unexpand(["            "], 4) eq "			", '12 spaces were converted to 3 tabs.';
ok unexpand([expand(["			"], 4)], 4) eq "			", "unexpand and expand are even";
