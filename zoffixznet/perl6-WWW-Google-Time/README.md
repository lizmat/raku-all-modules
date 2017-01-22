[![Build Status](https://travis-ci.org/zoffixznet/perl6-WWW-Google-Time.svg)](https://travis-ci.org/zoffixznet/perl6-WWW-Google-Time)

# NAME

WWW::Google::Time - Perl 6 module to get time for various locations using Google

# SYNOPSIS

```perl6
    use WWW::Google::Time;

    my %time = google-time-in 'Toronto';
    say "Time in %time<where> is %time<str>";
    # Prints: Time in Toronto, ON is 9:25 AM EST, Monday, December 7, 2015

    # Full version:
    say qq:to/END/
        Location:         %time<where>
        Time:             %time<time>
        Time zone:        %time<tz>
        Day of the week:  %time<week-day>
        Month:            %time<month>
        Day of the month: %time<month-day>
        Year:             %time<year>
        Full time string: %time<str>
        DateTime object:  %time<DateTime>
    END

    # Prints:
    #    Location:         Toronto, ON
    #    Time:             9:31 AM
    #    Time zone:        EST
    #    Day of the week:  Monday
    #    Month:            December
    #    Day of the month: 7
    #    Year:             2015
    #    Full time string: 9:31 AM EST, Monday, December 7, 2015
    #    DateTime object:  2016-12-22T09:31:48.651773-05:00
```

# DESCRIPTION

This module lets you find out the current time in various locations around
the globe using Google.

# EXPORTED SUBROUTINES

## `google-time-in`

```perl6
    my %time = google-time-in 'Toronto';
```

Uses Google to fetch time for specified location. Will
[fail](http://docs.perl6.org/routine/fail) if a network
error occurs or if the location cannot be found. On success, returns a hash
with the following keys:

### `where`

```perl6
    # Location: Toronto, ON
    say "Location: %time<where>"
```
The location for which the time data is provided. Note this might be slightly
different from the original location you provided to `google-time-in`.

### `time`

```perl6
    # Time: 9:31 AM
    say "Time: %time<time>"
```
The current time in `AM`/`PM` format.

### `tz`

```perl6
    # Time zone: EST
    say "Time zone: %time<tz>"
```
The time zone.

### `week-day`

```perl6
    # Day of the week: Monday
    say "Day of the week: %time<week-day>"
```

### `month`

```perl6
    #  Month: December
    say "Month: %time<month>"
```
The name of the month.

### `month-day`

```perl6
    #  Day of the month: 7
    say "Day of the month: %time<month-day>"
```
The day of the month (1–31).

### `year`

```perl6
    # Year: 2015
    say "Year: %time<year>"
```
The year.

### `str`

```perl6
    # Full time string: 9:31 AM EST, Monday, December 7, 2015
    say "Full time string: %time<str>"
```
Convenience key that combines most of the above keys into a single
human-readable string.

### `DateTime`

```perl6
    # DateTime object:  2016-12-22T09:31:48.651773-05:00
    say "DateTime object:  %time<DateTime>";
```

Contains a [`DateTime`](https://docs.perl6.org/type/DateTime) object,
representing the time. Since seconds are not available from Google, the seconds
in the object are set via `59.999 min DateTime.now.utc.second` and thus depend
on the local time of the machine the code is running on.

*Note*: the timezone offset is derived from a hardcoded map of timezone
abbreviation-to-offset and if the abbreviation cannot be decoded, offset of
0 is used. I have no guarantees that map includes every possible timezone
abbreviation Google may return.

# SEE ALSO

Google's Terms of Service: https://www.google.com/intl/en/policies/terms/

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-WWW-Google-Time

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-WWW-Google-Time/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
