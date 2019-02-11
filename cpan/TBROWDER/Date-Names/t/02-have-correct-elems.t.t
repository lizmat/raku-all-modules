use v6;
use Test;

plan 40;

use Date::Names :ALL;

for @lang -> $L {
    is %(%mon{$L}).elems, 12;
    is %(%mon3{$L}).elems, 12;
}

for @lang -> $L {
    is %(%dow{$L}).elems, 7;
    is %(%dow3{$L}).elems, 7;
    is %(%dow2{$L}).elems, 7;
}

