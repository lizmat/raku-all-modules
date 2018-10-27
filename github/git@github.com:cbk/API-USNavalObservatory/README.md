# perl6-API-USNavalObservatory [![Build Status](https://travis-ci.org/cbk/API-USNavalObservatory.svg?branch=master)](https://travis-ci.org/cbk/API-USNavalObservatory)

## SYNOPSIS
Simple Perl 6 interface to the U.S. Naval Observatory, Astronomical Applications API v2.0.1
which can be found at http://aa.usno.navy.mil/data/docs/api.php

You may choose  to use an 8 character alphanumeric identifier in your forms or scripts.  This API has a default of 'P6mod' which is registered with the U.S. Naval Observatory as the default ID of this API.  The 'AA' ID is used internally by the U.S. Naval Observatory and thus can not be used.
You may use any other identifier you want to ID
#### EXAMPLE:
the following example creates a new API::NavalObservatory object called $webAgent and sets the apiID to 'MyID'.
```
my $webAgent = API::NavalObservatory.new( apiID => "MyID" );
```

## Methods

### Day and Night Across the Earth - Cylindrical Projection
#### EXAMPLE:
#### Return:

### Day and Night Across the Earth - Spherical Projection
#### EXAMPLE:
#### Return:

### Day and Night Across the Earth - Cylindrical Projection
#### EXAMPLE:
#### Return:

### Day and Night Across the Earth - Spherical Projections
#### EXAMPLE:
#### Return:
This method returns a JSON formatted text blob.

### Apparent Disk of a Solar System Object
#### EXAMPLE:
#### Return:
This method returns a JSON formatted text blob.

### Phases of the Moon
#### EXAMPLE:
#### Return:
This method returns a JSON formatted text blob.

### Complete Sun and Moon Data for One Day
#### EXAMPLE:
#### Return:
This method returns a JSON formatted text blob.

### Sidereal Time
Provides the greenwich mean and apparent sidereal time, local mean and apparent sidereal time, and the Equation of the Equinoxes for a given date & time.


#### EXAMPLE:

```
my $request = $webAgent.siderealTime(
	:dateTimeObj($dateTimeData),
	:coords('41.98N, 12.48E'),
	:reps(90),
	:intvMag(5),
	:intvMag('minutes')
);
```

#### Return:
This method returns a JSON formatted text blob.

### Solar Eclipse Calculator
This data service provides local circumstances for solar eclipses, and also provides a means for determining dates and types of eclipses in a given year.

#### EXAMPLE:
The following example shows a request using a U.S. based location.

```
my $request = $webAgent.solarEclipses(
	:loc("San Francisco, CA"),
	:dateTimeObj($dateTimeData),
	:height(50),
	:format("json") );
```
The following example shows a request using lat and long.

```
my $request = $webAgent.solarEclipses(
	:loc("San Francisco, CA"),
	:dateTimeObj($dateTimeData),
	:height(50),
	:format("json") );
```

#### Return:
This method returns a JSON formatted text blob.

### Selected Christian Observances
This data service provides the dates of Ash Wednesday, Palm Sunday, Good Friday, Easter, Ascension Day, Whit Sunday, Trinity Sunday, and the First Sunday of Advent in a given year. Data will be provided for the years 1583 through 9999. More information about this application may be found here

#### EXAMPLE:
`my $request = $webAgent.observancesChristan( :year(2017) );`
#### Return:
This method returns a JSON formatted text blob.

### Selected Jewish Observances
This data service provides the dates for Rosh Hashanah (Jewish New Year), Yom Kippur (Day of Atonement), first day of Succoth (Feast of Tabernacles), Hanukkah (Festival of Lights), first day of Pesach (Passover), and Shavuot (Feast of Weeks) in a given year. Data will be provided for the years 360 C.E. (A.M. 4120) through 9999 C.E. (A.M. 13761).

#### EXAMPLE:
`my $request = $webAgent.observancesJewish( :year(2017) );`
#### Return:
This method returns a JSON formatted text blob.

### Selected Islamic Observances
This data service provides the dates for Islamic New Year, the first day of Ramadân, and the first day of Shawwál in a given year.

The `.observancesIslamic` method takes one argument called year, which should be a unsigned integer in the range of 622 to 9999.

#### EXAMPLE:
`my $request = $webAgent.observancesIslamic( :year(2017) );`

#### Return:
This method returns a JSON formatted text blob.


### Julian Date Converter
This data service converts dates between the Julian/Gregorian calendar and Julian date. Data will be provided for the years 4713 B.C. through A.D. 9999, or Julian dates of 0 through 5373484.5.

To use the `.julianDate` method, you must provide a valid `DateTime` object and a valid Era OR an unsigned integer.

This method returns a JSON text blob of the request converted into ether a Julian or calendar date.


#### EXAMPLES:

`my $request = $webAgent.julianDate( 2457892.312674 );`

`my $request = $webAgent.julianDate( DateTime.now, 'AD');`
#### Return:
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
