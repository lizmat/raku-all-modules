use v6;
use Test;

use Text::More :ALL;

plan 3;

is count-substrs('23:::', '::'), 2;
is count-substrs('d:efa33:23:::', ':'), 5;
is count-substrs('d-:efa33:23:-::', '-:'), 2;
