use v6.c;
use Test;
use Time::localtime;

plan 20;

sub ok-time($t, $what) {
    ok 0 <= $t.sec   <=  60, "is $what second in range";
    ok 0 <= $t.min   <=  59, "is $what minute in range";
    ok 0 <= $t.hour  <=  23, "is $what hour in range";
    ok 1 <= $t.mday  <=  31, "is $what day in month in range";
    ok 0 <= $t.mon   <=  11, "is $what month in range";
    ok 0 <= $t.year        , "is $what year in range";
    ok 0 <= $t.wday  <=   6, "is $what day in week in range";
    ok 1 <= $t.yday  <= 366, "is $what day in year in range";
    ok 0 <= $t.isdst <=   1, "is $what is daylight saving time in range";
}

ok-time localtime, 'localtime';
ok-time localtime(1527362356), 'localtime(1527362356)';

sub ok-ctime($t, $what) {
    ok $t ~~ m/^ \w\w\w \s \w\w\w \s+ \d+ \s \d\d\:\d\d\:\d\d \s \d\d\d\d $/,
      "is $what string correctly formatted";
}

ok-ctime ctime, 'localtime string';
ok-ctime ctime(1527362356), 'localtime(1527362356) string';

# vim: ft=perl6 expandtab sw=4
