# perl6-API-USNavalObservatory [![Build Status](https://travis-ci.org/cbk/API-USNavalObservatory.svg?branch=master)](https://travis-ci.org/cbk/API-USNavalObservatory)

## SYNOPSIS
Simple Perl 6 interface to the U.S. Naval Observatory, Astronomical Applications API v2.0.1
This is a work in progress is is by any means ready for use yet.  More to follow...


my $webAgent = API::NavalObservatory.new( apiID => "MyID" );


## Methods


#### Day and Night Across the Earth - Cylindrical Projection

#### Day and Night Across the Earth - Spherical Projection

#### Day and Night Across the Earth - Cylindrical Projectio

### Day and Night Across the Earth - Spherical Projections


#### Apparent Disk of a Solar System Object

#### Phases of the Moon

#### Complete Sun and Moon Data for One Day

#### Sidereal Time

#### Solar Eclipse Calculator

#### Selected Christian Observances

#### Selected Jewish Observances


#### Selected Islamic Observances
This data service provides the dates for Islamic New Year, the first day of Ramadân, and the first day of Shawwál in a given year.

The `.observancesIslamic` method takes one argument called year, which should be a unsigned integer in the range of 622 to 9999.

##### EXAMPLE:
`my $request = $webAgent.observancesIslamic( :year(2017) );`

#### Julian Date Converter
This data service converts dates between the Julian/Gregorian calendar and Julian date. Data will be provided for the years 4713 B.C. through A.D. 9999, or Julian dates of 0 through 5373484.5. More information about this application may be found here.

To use the `.julianDate` method, you must provide a valid `DateTime` object and a valid Era OR an unsigned integer.

This method returns a JSON text blob of the request converted into ether a Julian or calendar date.


##### EXAMPLES:

`my $request = $webAgent.julianDate( 2457892.312674 );`

`my $request = $webAgent.julianDate( DateTime.now, 'AD');`
##### Return:
This method returns a JSON formatted text blob.


## Returns
* For services which return text, you will receive an JSON formatted blob of text.
* For services which produce a image, this API will save the .PNG file in the current working directory.

## Example
* The following example makes a new object and overrides the default apiID. Then calls the Julian date converter method to find the converted Julian date.

```
use v6.c;
use API::USNavalObservatory;
my $webAgent = API::NavalObservatory.new( apiID => "MyID" );
my $output = $webAgent.julianDate( 2457892.312674 );
say $output;

```
OUTPUT:
```
SOME TEXT HERE...
```

## AUTHOR
* Michael, cbk on #perl6, https://github.com/cbk/
