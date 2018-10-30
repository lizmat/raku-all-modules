use v6;

BEGIN @*INC.unshift('lib');

use Test;

plan 1;

use IUP;

ok 1, 'IUP is loaded successfully';

done;
