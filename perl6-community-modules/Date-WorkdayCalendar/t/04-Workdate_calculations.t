use v6;
use Test; plan 4 * 17;

use Date::WorkdayCalendar;

my $FILE_CAL_CORRECT = 't/res/CORRECT.cal';

diag "Testing workdays-to v/s net-workdays, using $FILE_CAL_CORRECT";

my WorkdayCalendar $calendar .= new($FILE_CAL_CORRECT);

#--- These are the expected values for the functions
#                    Spreadsheet's 
#                     NETWORKDAYS  workdays-to   networkdays	
#                  Left-Right R-L    L-R R-L	   L-R R-L   
my $test_list =
'2011-07-07 2011-07-14   6  -6        5  -5         6  -6
2011-07-07 2011-07-07    1   1        0   0         1   1
2011-07-07 2011-07-01   -5   5       -4   4        -5   5
2011-01-01 2011-01-01    0   0        0   0         0   0
2011-01-01 2011-01-02    0   0        0   0         0   0
2011-01-01 2011-01-03    1  -1        1   0         1  -1
2011-07-01 2011-07-05    3  -3        2  -2         3  -3
2011-07-02 2011-07-22    15 -15       15 -14        15 -15
2011-07-01 2011-07-22    16 -16       15 -15        16 -16
2011-09-15 2011-09-22    4  -4        3  -3         4  -4
2011-09-16 2011-09-22    3  -3        2  -2         3  -3
2011-09-17 2011-09-22    2  -2        2  -1         2  -2
2011-09-17 2011-09-20    0   0        0   0         0   0
2011-09-22 2011-09-15   -4   4       -3   3        -4   4
2011-09-18 2011-09-22    2  -2        2  -1         2  -2
2011-09-22 2011-09-23    2  -2        1  -1         2  -2
2011-09-18 2011-09-15   -2   2       -2   1        -2   2';


my @tests = $test_list.split(/\n/);
my $t = "A";
for (@tests) -> $line {
    my @fields = $line.split(/\s+/);
    my $d1 = Date.new(shift @fields);
    my $d2 = Date.new(shift @fields);
    my (Int $NW1, Int $NW2, Int $wt1, Int $wt2, Int $nw1, Int $nw2) = @fields.map({ .Int });
    diag "Test $t";
    $t++;
    is(
        $calendar.workdays-to($d1, $d2), $wt1,
        "Workdate calculations : workdays-to($d1, $d2) == $wt1"
    );
    is(
        $calendar.workdays-to($d2, $d1), $wt2,
        "Workdate calculations : workdays-to($d2, $d1) == $wt2"
    );
    is(
        $calendar.networkdays($d1, $d2), $NW1,
        "Workdate calculations : networkdays($d1, $d2) == $NW1"
    );
    is(
        $calendar.networkdays($d2, $d1), $NW2,
        "Workdate calculations : networkdays($d2, $d1) == $NW2"
    );
};
