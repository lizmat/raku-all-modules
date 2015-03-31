use v6;

BEGIN { @*INC.push('lib') };

use Test;

plan 1;

use Browser::Open;
ok 1, "'use Browser::Open' worked!";
