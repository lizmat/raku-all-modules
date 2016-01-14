# MaxMind GeoIP legacy free/pro interface

[![Build Status](https://travis-ci.org/bbkr/GeoIPerl6.svg?branch=master)](https://travis-ci.org/bbkr/GeoIPerl6)

Currently City databases are supported.

Country, Region, Organization or ISP support may follow.

## SYNOPSIS

```perl6
    use GeoIP::City;
    
    my $gc = GeoIP::City.new;
    
    say $gc.locate( '8.8.8.8' );                # IPv4
    say $gc.locate( '2001:4860:4860::8888' );   # IPv6
```

## METHODS

### new( directory => '/home/me/geoip' )

Initialize databases.

Optional ```directory``` param overwrites default databases location,
which may be useful for customized [geoipupdate](http://dev.maxmind.com/geoip/geoipupdate/) configuration and/or non-root users.

### info

Check available database versions.

```perl6
    {
        'GEOIP_CITY_EDITION_REV1' => 'GEO-533LITE 20151103 Build 1...',
        'GEOIP_CITY_EDITION_REV1_V6' => 'GEO-536LITE 20151103 Build 1...'
    }
```

### locate ( $ip )

Find geo location for given IPv4 or IPv6 address.

Amount of fields in response may vary, below is the most complete one:

```perl6
    {
        'area_code' => 650,
        'city' => 'Mountain View',
        'continent_code' => 'NA',
        'country' => 'United States',
        'country_code' => 'US',
        'dma_code' => 807,
        'latitude' => 37.384499,
        'longitude' => -122.088097,
        'postal_code' => '94040',
        'region' => 'California',
        'region_code' => 'CA',
        'time_zone' => 'America/Los_Angeles'
    }
```
 
If geo location for IP was not found then ```Nil``` is returned.

If database for given IP version is not available then ```GeoIP::City::X::DatabaseMissing``` exception is thrown.

## REQUIREMENTS

MaxMind [GeoIP C library](https://github.com/maxmind/geoip-api-c)
and [City legacy databases](http://dev.maxmind.com/geoip/legacy/geolite/) are required.

### Ubuntu Linux

In terminal enter:

```bash
    sudo apt-get install libgeoip1 geoip-database-contrib
    sudo ln -s /usr/share/GeoIP/GeoLiteCityv6.dat /usr/share/GeoIP/GeoIPCityv6.dat
```

### Mac OS X

Install [Xcode](https://developer.apple.com/xcode/) from AppStore, then install [HomeBrew](http://brew.sh).

In terminal enter:

```bash
    brew install geoip geoipupdate
    geoipupdate
    ln -s /usr/local/var/GeoIP/GeoLiteCityv6.dat /usr/local/var/GeoIP/GeoIPCityv6.dat
```

### geoipupdate

To obtain databases through [geoipupdate](http://dev.maxmind.com/geoip/geoipupdate/) use following names as ```ProductIds```:

* ```533``` - Free IPv4 database. File ```GeoLiteCity.dat``` must be linked as ```GeoIPCity.dat```.
* ```133``` - Paid IPv4 database. In this case you also need valid license filled.
* ```GeoLite-Legacy-IPv6-City``` - Free IPv6 database. File ```GeoLiteCityv6.dat``` must be linked as ```GeoIPCityv6.dat```.
(there is no paid version of IPv6 database)

***Warning:*** Make sure your geoipupdate uses the same directory that libGeoIP expects. Or pass it explicitly to ```new( )```.

***Warning:*** Do not use old REV0 databases (for example paid ```ProductIds``` = ```132```).


## LICENSE

Released under [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

## CONTACT

You can find me (and awesome people who helped me to develop this module)
on irc.freenode.net #perl6 channel as **bbkr**.
