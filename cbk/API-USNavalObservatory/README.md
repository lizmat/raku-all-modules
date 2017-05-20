# perl6-API-USNavalObservatory [![Build Status](https://travis-ci.org/cbk/API-USNavalObservatory.svg?branch=master)](https://travis-ci.org/cbk/API-USNavalObservatory)


## SYNOPSIS
Simple Perl 6 interface to the U.S. Naval Observatory, Astronomical Applications API v2.0.1

This is a work in progress is is by any means ready for use yet.  More to follow...

## Methods
* observancesChristan( UInt $year )
This method take a 4 digit year from 1583 to 9999.
* observancesJewish( UInt $year )
This method take a 4 digit year from 622 to 9999.
* observancesIslamic( UInt $year )
This method take a 4 digit year from 360 to 9999.
* julianDate( $dateTimeObj, $era )
This method take a DateTime object and one of the valid era aberrations .
* julianDate( $julian )

## Returns
 *

## Example
```
use v6.c;
use API::USNavalObservatory;
my $webAgent = API::NavalObservatory.new;
my $output = $webAgent.julianDate( 2457892.312674 );
say $output;
```

## TODO
 *
