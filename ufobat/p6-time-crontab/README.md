NAME
====

Time::Crontab for perl6

SYNOPSIS
========

	use Time::Crontab;
	my $crontab = "* * * * *";
	my $tc = Time::Crontab.new(:$crontab);
	if $tc.match(DateTime.now, :truncate(True)) { ..... }

METHODS
=======

* `new(Str :$crontab!, Int :$timezone = 0) returns DateTime:D`

* `match(DateTime $datetime, Bool :$truncate = False) returns Bool:D`

Matches the $datetime against the crontab specification. Since the crontab's smallest granulation is minute wise there is a option to $truncate the $datetime to minutes when it comes to consideration if the $datetime matches the $crontab.

* `next-datetime(DateTime $datetie) returns DateTime:D`

Calculates the next execution right after $datetime.

SYNTAX OF THE CRONTAB
=====================

    Field name   Allowed values  Allowed special characters
    Minutes      0-59            * / , - !
    Hours        0-23            * / , - !
    Day of month 1-31            * / , - !
    Month        1-12 or JAN-DEC * / , - !
    Day of week  0-6 or SUN-SAT  * / , - !

* `*` means anything. The actual values depends on the field.
* `/` is a stepping. This special character must be followed bit a number, which decribes the step size.
* `,` can be used to list different values, or ranges.
* `-` indicates a range.
* `!` excludes a value.

The names of the month or day of the week are the first 3 characters of their english names. They are case insensetive.

DAY OF MONTH VS DAY OF WEEK
===========================

The Handling of the Day of Week and Day of Month is quite delicate. In the case that the Day of Week field is set to any (*) you basically dont care for it.

This is borrowd from the crontab 5 manpage

     Note: The day of a command's execution can be specified by two fields — day of month, and day of week.  If both fields are restricted (i.e., aren't *), the command  will  be
     run when either field matches the current time.  For example,
     ``30  4  1,15 * 5'' would cause a command to be run at 4:30 am on the 1st and 15th of each month, plus every Friday. One can, however, achieve the desired result by adding a
     test to the command (see the last example in EXAMPLE CRON FILE below).

     # run five minutes after midnight, every day
     5 0 * * *       $HOME/bin/daily.job >> $HOME/tmp/out 2>&1
     # run at 2:15pm on the first of every month -- output mailed to paul
     15 14 1 * *     $HOME/bin/monthly
     # run at 10 pm on weekdays, annoy Joe
     0 22 * * 1-5    mail -s "It's 10pm" joe%Joe,%%Where are your kids?%
     23 0-23/2 * * * echo "run 23 minutes after midn, 2am, 4am ..., everyday"
     5 4 * * sun     echo "run at 5 after 4 every sunday"
     # Run on every second Saturday of the month
     0 4 8-14 * *    test $(date +\%u) -eq 6 && echo "2nd Saturday"
