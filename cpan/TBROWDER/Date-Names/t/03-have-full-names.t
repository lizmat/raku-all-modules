use v6;
use Test;

plan 152;

use Date::Names;

# all langs must have mon and dow values
for 1..12 -> $mon {
    for @lang -> $L {
        my $val = $::("Date::Names::{$L}::mon"){$mon};
        ok $::("Date::Names::{$L}::mon"){$mon}, "lang $L; hash mon, month $mon, val $val";
    }
}

for 1..7 -> $day {
    for @lang -> $L {
        my $val = $::("Date::Names::{$L}::dow"){$day};
        ok $::("Date::Names::{$L}::dow"){$day}, "lang $L; hash dow, day $day, val $val";
    }
}
