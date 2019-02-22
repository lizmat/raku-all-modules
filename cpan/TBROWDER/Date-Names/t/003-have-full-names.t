use v6;
use Test;

plan 171;

use Date::Names;

# all langs must have mon and dow values
my @langs = @Date::Names::langs;
for 1..12 -> $mon {
    for @langs -> $L {
        my $val = $::("Date::Names::{$L}::mon")[$mon-1];
        ok $::("Date::Names::{$L}::mon")[$mon-1], "lang $L; array mon, month $mon, val $val";
    }
}

for 1..7 -> $day {
    for @langs -> $L {
        my $val = $::("Date::Names::{$L}::dow")[$day-1];
        ok $::("Date::Names::{$L}::dow")[$day-1], "lang $L; array dow, day $day, val $val";
    }
}
