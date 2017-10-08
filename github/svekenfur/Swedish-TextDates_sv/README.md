NAME
====

TextDates_sv 

VERSION
=======

Version: 0.1.2

SYNOPSIS
========

    use Swedish::TextDates_sv;

    # Let us pretend that todays date is 2017-07-12.
    # First the date (fancy):
    my $date = Whole-Date-Names_sv.new(whole_date => DateTime.now.yyyy-mm-dd);
    say $date.fancy-date; # --> (tolfte juli 2017) 

    # Or as recommended in https://webbriktlinjer.se/66
    my $date = Whole-Date-Names_sv.new(whole_date => DateTime.now.yyyy-mm-dd);
    say $date.formal-date; # --> (12 juli 2017) 

    # Day of week:
    my $day = Day-Of-Week-Name_sv.new(day_of_week_number => DateTime.now.day-of-week);
    say $day.get-day-name_sv; # --> onsdag 

    # Day of week in short form:
    my $shortday = Day-Of-Week-Name_sv.new(day_of_week_number => DateTime.now.day-of-week);
    say $shortday.get-day-name-short_sv; # --> ons

DESCRIPTION
===========

TextDates_sv transforms the digits in a date or the weekday number to the Swedish text equivalent.  If an invalid date or day of week is provided, for example 2017-02-31, TextDates_sv will print a message to `$*ERR` and exit.

INSTALLATION
============

With zef:

zef install https://github.com/svekenfur/Swedish-TextDates_sv.git 

USAGE
=====

See the **SYNOPSIS** above, that is pretty much all of it.

CHANGES
=======

Changes since version 0.1.1:

### In class Whole-Date-Names_sv:

  * Method 'date-to-text' renamed to 'fancy-date'.

  * Method 'formal-date' added.

### Other changes:

  * Array with short names of months added.

BUGS
====

TextDates_sv has only been tested on a machine with MS Windows 7 and Rakudo 2017.04.3. To report bugs or request features, please use https://github.com/svekenfur/Swedish-TextDates_sv/issues.

SEE ALSO
========

[https://webbriktlinjer.se/66](https://webbriktlinjer.se/66) PTS - Vägledning för webbutveckling - Riktlinje nr 66 (Page in Swedish).

AUTHOR
======

Sverre Furberg

LICENCE
=======

You can use and distribute this module under the terms of the The Artistic License 2.0.
