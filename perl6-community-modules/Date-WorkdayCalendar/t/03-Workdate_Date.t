use v6;
use Test; plan 7;

use Date::WorkdayCalendar;

my $FILE_CAL_CORRECT = 't/res/CORRECT.cal';

diag "Testing the creation of a Workdate from a Date";
my Date $d .= new('2000-06-20');
my Workdate $wd .= new($d);
ok(    
    ($wd.year == $d.year) & ($wd.month == $d.month) & ($wd.day == $d.day),
    'Workdate based on a Date'
);    

diag "Testing Date and Workdate operators";
my $d1  = Date.new('2011-09-15'); #Thursday
my $d2  = Date.new('2011-09-18'); #Sunday
my $wd1 = Workdate.new('2011-09-15');
my $wd2 = Workdate.new('2011-09-18');
my $wd3 = Workdate.new('2011-09-19', calendar=>WorkdayCalendar.new($FILE_CAL_CORRECT)); #Holiday

is( #--- Minus operator; Pure dates
    $d2 - $d1, 3,
    "Date - Date"
);
is( #--- Date - same Workdate
    $d2 - $wd2, 0,
    "same Date - same Workdate"
);
is( #--- Workdate - same Date
    $wd2 - $d2, 0,
    "same Workdate - same Date"
);

is( #--- Minus operator; one Date with one Workdate
    $d2 - $wd1, 3,
    "Date - Workdate"
);
is( #--- Minus operator; one Date with one Workdate
    $wd2 - $d1, 3,
    "Workdate - Date"
);
is( #--- Minus operator; two Workdates
    ($wd2 - $wd1), 2,
    "Workdate - Workdate"
);
