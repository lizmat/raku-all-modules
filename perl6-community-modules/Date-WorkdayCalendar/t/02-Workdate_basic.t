use v6;
use Test; plan 18;

use Date::WorkdayCalendar;

my $FILE_CAL_CORRECT = 't/res/CORRECT.cal';

diag "Testing Workdate constructors, no calendar specified";
lives_ok(
    { my $wd = Workdate.new(year=>2012, day=>20, month=>1) },
    'Constructor with named parameters'
);
lives_ok(
    { my $wd = Workdate.new(2012, 1, 20) },
    'Constructor with positional parameters'
);
lives_ok(
    { my $wd = Workdate.new('2012-01-20') },
    'Constructor with date as a string'
);
lives_ok(
    { my $wd = Workdate.new( DateTime.new(year=>2011, month=>12, day=>1, hour=>15, minute=>30) ) },
    'Constructor from a DateTime'
);
lives_ok(
    { my $wd = Workdate.new( Date.new(year=>2011, month=>12, day=>1) ) },
    'Constructor from a Date'
);
my $calendar = WorkdayCalendar.new($FILE_CAL_CORRECT);

diag "Testing Workdate constructors, with a calendar specified";
lives_ok(
    { my $wd = Workdate.new(year=>2012, day=>20, month=>1, calendar=>$calendar) },
    'Constructor with named parameters, with a calendar specified'
);
lives_ok(
    { my $wd = Workdate.new(2012, 1, 20, $calendar) },
    'Constructor with positional parameters, , with a calendar specified'
);
lives_ok(
    { my $wd = Workdate.new('2012-01-20', $calendar) },
    'Constructor with date as a string, with a calendar specified'
);
lives_ok(
    { my $wd = Workdate.new( DateTime.new(year=>2011, month=>12, day=>1, hour=>15, minute=>30), $calendar ) },
    'Constructor from a DateTime, with a calendar specified'
);
lives_ok(
    { my $wd = Workdate.new( Date.new(year=>2011, month=>12, day=>1), $calendar ) },
    'Constructor from a Date, with a calendar specified'
);

diag "Testing Workdate class, using $FILE_CAL_CORRECT";
my Workdate $w_date = Workdate.new('2011-12-09', $calendar);

ok (
    $w_date.WHAT eq 'Workdate()',
    'Type "Workdate" correct'
);
say $w_date.^attributes.list;
ok(
    '$!calendar' eq any($w_date.^attributes.list),
    'The Workdate contains a calendar attribute'
);

is( #--- Friday to Monday
    $w_date.succ,
    Date.new('2011-12-12'),
    "Workdate class: Skipping weekends (Friday's succesor = Monday)"
);

is( #--- Friday to Wednesday (Thursday is holiday)
    $w_date.pred,
    Date.new('2011-12-07'),
    "Workdate class: Skipping holidays (Friday's predecesor = Wednesday, with Thursday as holiday)"
);
is( #--- method workdays-to with one parameter
    $w_date.workdays-to( Date.new('2011-12-07') ), -1,
    "Workdate class: workdays-to method" 
);
is( #--- method networkdays with one parameter
    $w_date.networkdays( Date.new('2011-12-07') ), -2,
    "Workdate class: networkdays method"
);

my $w_date2 = Workdate.new('2011-12-09');
$calendar.clear; 
is( #--- No holidays specified
    $w_date2.pred, Date.new('2011-12-08'),
    "Workdate class: 'Clear' calendar with no holidays"
);
my $w_date3 = Workdate.new('2011-09-16');
is( #--- Friday to Monday, no holidays
    $w_date3.succ, Date.new('2011-09-19'),
    "Workdate class: Using default calendar with no holidays and default workweek"
);

