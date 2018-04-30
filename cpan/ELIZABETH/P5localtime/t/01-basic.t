use v6.c;
use Test;
use P5localtime;

plan 44;

ok defined(::('&localtime')),
  'is &localtime imported?';
ok !defined(P5localtime::{'&localtime'}),
  'is &localtime externally NOT accessible?';
ok defined(::('&gmtime')),
  'is &gmtime imported?';
ok !defined(P5localtime::{'&gmtime'}),
  'is &gmtime externally NOT accessible?';

sub ok-list-time(@t, $type, \dst) {
    ok 0 <= @t[0] <=  59, "is $type second in range";
    ok 0 <= @t[1] <=  59, "is $type minute in range";
    ok 0 <= @t[2] <=  23, "is $type hour in range";
    ok 0 <= @t[3] <=  31, "is $type day in month in range";
    ok 0 <= @t[4] <=  11, "is $type month in range";
    ok 0 <= @t[5]       , "is $type year in range";
    ok 0 <= @t[6] <=   6, "is $type day in week in range";
    ok 0 <= @t[7] <= 366, "is $type day in year in range";
    ok 0 <= @t[8] <= dst, "is $type is daylight saving time in range";
}

ok-list-time localtime, 'localtime', 1;
ok-list-time    gmtime, 'gmtime',    0;

ok-list-time localtime(1525034924), 'localtime(1525034924)', 1;
ok-list-time    gmtime(1525034924), 'gmtime(1525034924)',    0;

sub ok-scalar-time($t, $type) {
    dd $t unless
    ok $t ~~ m/^ \w\w\w \s \w\w\w \s \d\d \s \d\d\:\d\d\:\d\d \s \d\d\d\d $/,
      "is $type string correctly formatted";
}

ok-scalar-time localtime(:scalar), 'localtime string';
ok-scalar-time    gmtime(:scalar), 'gmtime string';

ok-scalar-time localtime(1525034924, :scalar), 'localtime(1525034924) string';
ok-scalar-time    gmtime(1525034924, :scalar), 'gmtime(1525034924) string';

# vim: ft=perl6 expandtab sw=4
