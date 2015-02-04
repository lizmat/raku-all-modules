use v6;

BEGIN { @*INC.push('lib') };

use Test;

plan 1;

use Totem;
ok 1, "'use Totem' worked!";
