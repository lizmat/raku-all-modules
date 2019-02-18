use v6;
use Test;

plan 64;

use Date::Names;

for @lang -> $L {
    is $::("Date::Names::{$L}::mon").elems, 13;
    is $::("Date::Names::{$L}::mon2").elems, 13;
    is $::("Date::Names::{$L}::mon3").elems, 12;
    is $::("Date::Names::{$L}::mona").elems, 12;
}

for @lang -> $L {
    is $::("Date::Names::{$L}::dow").elems, 7;
    is $::("Date::Names::{$L}::dow2").elems, 7;
    is $::("Date::Names::{$L}::dow3").elems, 7;
    is $::("Date::Names::{$L}::dowa").elems, 7;
}
