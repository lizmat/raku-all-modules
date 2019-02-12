use v6;
use Test;

plan 64;

use Date::Names;

for @lang -> $L {
    is %Date::Names::mon{$L}.elems, 12;
    is %Date::Names::mon3{$L}.elems, 12;
}

for @lang -> $L {
    is %Date::Names::dow{$L}.elems, 7;
    is %Date::Names::dow3{$L}.elems, 7;
    is %Date::Names::dow2{$L}.elems, 7;
    is %Date::Names::dow{$L}.elems, 7;
    is %Date::Names::dow3{$L}.elems, 7;
    is %Date::Names::dow2{$L}.elems, 7;
}
