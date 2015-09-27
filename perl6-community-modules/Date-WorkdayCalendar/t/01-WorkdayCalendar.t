use v6;
use Test; plan 34;

use Date::WorkdayCalendar;

my $FILE_CAL_CORRECT     = 't/res/CORRECT.cal';
my $FILE_CAL_WITH_ERRORS = 't/res/WITH_ERRORS.cal';
my $FILE_CAL_SHORT_WEEK  = 't/res/SHORT_WEEK.cal';

#------------------------------------------------------------------------------#
diag 'Testing WorkdayCalendar constructors';
lives-ok {
    { my $calendar = WorkdayCalendar.new },
    "Constructing default calendar"
}
lives-ok {
    { my $calendar = WorkdayCalendar.new($FILE_CAL_CORRECT) },
    "Constructing calendar from a calendar file"
}

my $calendar = WorkdayCalendar.new;
is(
    $calendar.holidays.elems, 0,
    "No holidays defined"
);
ok(
    $calendar.workdays ~~ <Mon Tue Wed Thu Fri>,
    "Calendar has the default workweek"
);


#------------------------------------------------------------------------------#
diag 'Testing calendar operators';
my $calendar1 = WorkdayCalendar.new($FILE_CAL_CORRECT);
my $calendar2 = WorkdayCalendar.new($FILE_CAL_SHORT_WEEK);
my $calendar3 = WorkdayCalendar.new($FILE_CAL_SHORT_WEEK);
my $calendar4 = WorkdayCalendar.new($FILE_CAL_WITH_ERRORS);

diag "For comparing: calendar1 -> $FILE_CAL_CORRECT; calendar2 and calendar3 -> $FILE_CAL_SHORT_WEEK, calendar4 -> $FILE_CAL_WITH_ERRORS";
ok( #--- Calendar vs itself
    $calendar1 eq $calendar1,
    "calendar1 is equivalent (eq) to calendar1 (identity)"
);
ok( #--- Calendars with same holidays and same Workdates
    $calendar3 eq $calendar2,
    "calendar3 is equivalent (eq) to calendar2"
);
ok( #--- Calendars with distinct holidays and distinct workweek
    $calendar1 ne $calendar3,
    "calendar1 is not equivalent (ne) to calendar3"
);
diag 'Testing calendar ranges';
#--- $calendar1  has 2011-09-18, 19 and 20 as holidays
#--- $calendar4 has 2011-09-10, 18 and 19 as holidays
ok(
    $calendar1.range( Date.new('2011-09-15'), Date.new('2011-09-19') )
    eq
    $calendar4.range( Date.new('2011-09-15'), Date.new('2011-09-19') ),
    "calendar range: calendar and calendar4 are equivalent between 2011-09-15 and 2011-09-19"
);
ok(
    $calendar1.range( Date.new('2011-09-01'), Date.new('2011-09-25') )
    ne
    $calendar4.range( Date.new('2011-09-01'), Date.new('2011-09-25') ),
    "calendar range: calendar and calendar4 are not equivalent between 2011-09-01 and 2011-09-25"
);

#------------------------------------------------------------------------------#
diag "Testing correct calendar: $FILE_CAL_CORRECT";
$calendar.read($FILE_CAL_CORRECT);
ok(
    $calendar.file eq $FILE_CAL_CORRECT,
    "Reading calendar file"
); 
is(
    $calendar.holidays.elems, 13,
    "Counting well defined holidays"
);
ok(
    <Mon Tue Wed Thu Fri> ~~ $calendar.workdays,
    "Correct workweek (Monday to Friday)"
);
ok( #--- Specific Holiday
    $calendar.is-holiday( Date.new('2011-01-01') ),
    "2011-01-01 is a defined holiday"
);
ok( #--- Sunday
    $calendar.is-weekend( Date.new('2011-07-03') ),
    "2011-07-03 is part of the weekend"
);
ok( #--- Just another normal Tuesday
    $calendar.is-workday( Date.new('2011-02-01') ),
    "2011-02-01 is a Workdate"
);
is( #--- Friday to Monday
    $calendar.workdays-away( Date.new('2011-07-01'), +1 ),
    Date.new('2011-07-04'),
    "Skipping weekends (Friday + 1 = Monday)"
);
is( #--- Saturday (weekend) to Monday
    $calendar.workdays-away( Date.new('2011-07-02'), +1 ),
    Date.new('2011-07-04'),
    "Skipping weekends (Saturday + 1 = Monday)"
);
is( #--- Sunday (weekend) to Monday
    $calendar.workdays-away( Date.new('2011-07-03'), +1 ),
    Date.new('2011-07-04'),
    "Skipping weekends (Sunday + 1 = Monday)"
);
is( #--- Monday to Friday
    $calendar.workdays-away( Date.new('2011-07-04'), -1 ),
    Date.new('2011-07-01'),
    "Skipping weekends (Monday - 1 = Friday)"
);
is( #--- Monday to Monday
    $calendar.workdays-away( Date.new('2011-06-13'), +5 ),
    Date.new('2011-06-20'),
    "Skipping weekends (Monday + 5 = Monday)"
);
is( #--- Friday + 1 Holiday = Tuesday
    $calendar.workdays-away( Date.new('2011-06-24'), +1 ),
    Date.new('2011-06-28'),
    "Skipping holidays and weekends (Friday + 1 = Tuesday, with Monday as holiday)"
);
is( #--- Wednesday + 1 Holiday = Friday
    $calendar.workdays-away( Date.new('2011-12-07'), +1 ),
    Date.new('2011-12-09'),
    "Skipping holidays (Wednesday + 1 = Friday, with Thursday as holiday)"
);
is( #--- 2011-07-07 --> 2011-06-22
    $calendar.workdays-away( Date.new('2011-07-07'), -10 ),
    Date.new('2011-06-22'),
    "Skipping holidays and weekends (Thursday - 10 = Wednesday, with one Monday as holiday)"
);
is( #--- Counting 5 Workdates
    $calendar.workdays-to( Date.new('2011-07-07'), Date.new('2011-07-14') ), +5,
    "2001-07-07 is 5 Workdates before 2011-07-14"
);
is( #--- Counting -10 Workdates
    $calendar.workdays-to( Date.new('2011-07-07'), Date.new('2011-06-22') ), -10,
    "2001-07-07 is 10 Workdates after 2011-06-22"
);
is( #--- Counting 0 Workdates (all holidays)
    $calendar.workdays-to( Date.new('2011-09-18'), Date.new('2011-09-20') ), 0,
    "No Workdates between 2011-09-18 and 2011-09-20 (3 holidays in a row)"
);
is( #--- Counting 0 Workdates (Friday to Saturday)
    $calendar.workdays-to( Date.new('2011-07-01'), Date.new('2011-07-02') ), 0,
    "No Workdates between 2011-07-01 and 2011-07-02 (Friday to Saturday)"
);
is( #--- Friday to Tuesday
    $calendar.workdays-to( Date.new('2011-07-01'), Date.new('2011-07-05') ), 2,
    "2 Workdates between 2011-07-01 and 2011-07-05 (Friday to Tuesday)"
);
is( #--- Sunday to Thursday
    $calendar.workdays-to( Date.new('2011-09-18'), Date.new('2011-09-15') ), -2,
    "-2 Workdates between 2011-09-18 and 2011-09-15 (Sunday to Thursday)"
);
is( #--- Smaller set of holidays
    $calendar.range(Date.new('2011-05-01'), Date.new('2011-07-01')).holidays.elems, 3,
    "Calendar range between '2011-05-01' and '2011-07-01' has only 3 holidays"
);

#------------------------------------------------------------------------------#
diag "Testing short week calendar (Monday to Wednesday): $FILE_CAL_SHORT_WEEK";
$calendar.read($FILE_CAL_SHORT_WEEK);
ok( #--- Thursdays aren't Workdates in this calendar
    $calendar.is-weekend( Date.new('2011-07-28') ),
    "Thursday is not part of the workweek"
);
is( #--- Wednesday to Monday
    $calendar.workdays-away( Date.new('2011-03-02'), +1 ),
    Date.new('2011-03-07'),
    "Skipping weekends (Wednesday + 1 = Monday)"
);

#------------------------------------------------------------------------------#
diag "Testing calendar with errors: $FILE_CAL_WITH_ERRORS";
$calendar.read($FILE_CAL_WITH_ERRORS);
is(
    $calendar.holidays.elems, 12,
    "Counting well defined holidays (12 correct of 13 defined)"
);
is(
    $calendar.workdays, <Mon Tue Wed Thu Fri>,
    "Calendar has fallen back to the default weekdays"
);

