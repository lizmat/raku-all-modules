# Date::WorkdayCalendar

[![Build Status](https://travis-ci.org/perl6-community-modules/Date-WorkdayCalendar.svg?branch=master)](https://travis-ci.org/perl6-community-modules/Date-WorkdayCalendar)

The `WorkdayCalendar` and `Workdate` objects allow date calculations to be
made on a calendar that considers workdays (also called "business days").

Built on top of the `Date` datatype, it uses a calendar file to specify how
many days a workweek has and which days are to be considered holidays.

By default, the workweek is composed of Monday, Tuesday, Wednesday,
Thursday, and Friday.  Saturday and Sunday form the weekend.

Although most countries have a Monday to Friday workweek, some have very
different ones.

More information about workweeks can be found at
<http://en.wikipedia.org/wiki/Workweek>.

## Usage

    use v6;
    use Date::WorkdayCalendar;

    # construct a default workday calendar
    my $calendar = WorkdayCalendar.new;

    # work out the next workday away from the given date
    # 2016-11-18 is a Friday
    $calendar.workdays-away(Date.new('2016-11-18'), 1);  # 2016-11-21

    # construct a workday calendar from a file
    my $calendar-from-file = WorkdayCalendar.new('days.cal');

    # create a workdate from a date string
    my $workdate = Workdate.new('2016-05-02');

    # create a workdate from a Date object
    my $date = Date.new('2016-11-18');
    my $workdate-from-date = Workdate.new($date);

    # is the day a workday?
    $workdate = Workdate.new('2016-11-18');
    $workdate.is-workday;  # True
    $workdate.is-weekend;  # False
    $workdate.is-holiday;  # False

Detailed documentation is available in the [source code's
POD](https://github.com/perl6-community-modules/Date-WorkdayCalendar/blob/master/lib/Date/WorkdayCalendar.pm).

Comments, ideas and issues can be submitted to the [GitHub issue
tracker](https://github.com/perl6-community-modules/Date-WorkdayCalendar/issues)
or discussed on the #perl6 channel on irc.freenode.net.

## Installation

To install this module, simply use either `panda`:

    panda install Date::WorkdayCalendar

or `zef`:

    zef install Date::WorkdayCalendar

## Development

To develop the code, clone the source code repository from GitHub:

    git clone git@github.com:perl6-community-modules/Date-WorkdayCalendar.git

## Testing

To run the test suite on a local copy of the source code, use the following
command:

    prove -r --exec="perl6 -Ilib" t/

## Author

The original author of the module was shinobi <shinobi.cl@gmail.com>.  The
module is now maintained by The Perl6 Community.

## Copyright and License

Copyright 2012-2013 shinobi <shinobi.cl@gmail.com>

Copyright 2014-2016 The Perl6 Community

This program is distributed under the terms of the Artistic License 2.0.

For further information, please see the LICENSE file or visit
<http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt>.
