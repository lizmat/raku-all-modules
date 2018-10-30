# DateTime::TimeZone

## Introduction

TimeZone handling for Perl 6.

## Subroutines

### tz-offset(Str $offset-string) --> Int

Parses common offset strings and returns an Int value.

### timezone(Str $name, DateTime $datetime?) --> DateTime::TimeZone

Returns a TimeZone object representing the zone passed to it.
These objects provide an .Int call, so they may be used directly as
the :timezone parameter for a DateTime object.

This will support any timezone listed in the Olson database.

The $datetime is used to calculate the offset depending on Daylight Savings
Time rules for the given Time Zone.

If $datetime is not passed, it assumes DateTime.now();

### to-timezone(Str $name, DateTime $datetime)

A shortcut for: $datetime.in-timezone(timezone($name, $datetime));

## TODO

This is very much under development, and currently only the tz-offset()
subroutine is supported. 

## Authors

 * [Timothy Totten](https://github.com/supernovus/)
 * [Andrew Egeler](https://github.com/retupmoca/)

## License

[Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0)

