# NAME

DateTime::Format::LikeGo - format dates using Go's reference format

# SYNOPSIS

```perl6
use DateTime::Format::LikeGo;

# Format a date
say go-date-format("2006-01-02", DateTime.now);

# convert to strftime format:
say DateTime::Format::LikeGo::go-to-strftime("2006-01-02"); # %Y-%m-%d
```

# DESCRIPTION

A simple module that converts from Golang's "reference time" format to
strftime. The intention is for you to specify how a certain datetime would be
formatted, and it then can format any date in that style.

The reference date is 2006-01-02T15:04:05-0700, which is written as a series of
ascending digits, if rearranged, and 3pm is used instead of 15.

Inspired by complaints about the Go time format.

# FUNCTIONS

## go-date-format(Str $format, DateTime $date) is export returns Str

Format the given time according to the provided format string.

## go-to-strftime(Str $format) returns Str

Return the strftime version of the go format.

# EXCEPTIONS

A string exception is thrown if the converted strftime format has any digits
left over, which typically indicate a bad input format.

# CAVEATS

- Timezone support is missing in DateTime::Format, so strings using timezones
  will fail until it is added.
- Not well tested overall.

# REQUIREMENTS

- Rakudo Perl 6 2014.11 or above. Tested primarily on MoarVM.
- DateTime::Format

# SEE ALSO

http://fuckinggodateformat.com/ - inspiration for this module

[Documentation for Go's time package](http://golang.org/pkg/time/)

