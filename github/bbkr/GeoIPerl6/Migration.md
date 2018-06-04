# GeoIP v1 → v2 migration tutorial

## Install GeoIP2 module

Module [GeoIP2](https://github.com/bbkr/GeoIP2) is available in Perl 6 ecosystem.
This is Pure Perl so no additional C libraries are required.

## Download City database in new format

Name should end with `*.mmdb` instead of `*.dat` -
typically `GeoLite2-City.mmdb` is free and `GeoIP2-City.mmdb` is paid one.

There are no separate IPv4/IPv6 databases like in GeoIP v1.

Examples for MacOS, Ubuntu and Arch and are [here](https://github.com/bbkr/GeoIP2#requirements).

## Code changes

Old:
```
use GeoIP::City;

my $geo = GeoIP::City.new;

say $geo.locate( '8.8.8.8' );
say $geo.locate( '2001:4860:4860::8888' );
```

New:
```
use GeoIP2;

my $geo = GeoIP2.new( path => '/somewhere/GeoLite2-City.mmdb' );

say $geo.locate( ip => '8.8.8.8' );
say $geo.locate( ip => '2001:4860:4860:0:0:0:0:8888' );
```

Note:
* Doesn't matter how you got your database  - direct download form MaxMind, using geoipupdate tool or using software repository packages - you have to know its path to give it to the constructor. There is no hardcoded "default" path like in libgeoip C library.
* IP is changed from positional to named param.
* Compressed form of IPv6 with `::` is Not Yet Implemented. You have to replace `::` with correct amount of `0` sections yourself. Sorry!

### Result field mapping

GeoIP2 returns more complex result. Here is how to map new structure to old one:

```
my %new-result = $geo.locate( ip => '8.8.8.8' );

my %old-reuslt = (
    
    # gone, see https://dev.maxmind.com/geoip/geoip2/whats-new-in-geoip2/#Area_Code
    'area_code'         => Nil,
    
    'city'              => %new-result{ 'city' }{ 'names' }{ 'en' },
    
    'continent_code'    => %new-result{ 'continent' }{ 'code' },
    
    'country'           => %new-result{ 'country' }{ 'names' }{ 'en' },
    'country_code'      => %new-result{ 'country' }{ 'iso_code' },

    # whatever it was - it's gone
    'dma_code'          => Nil,
    
    # will be returned as IEEE754 Num
    # you should probably apply some sane rounding
    # like: %new-result{ 'location' }{ 'latitude' }.round(0.00001)
    'latitude'          => %new-result{ 'location' }{ 'latitude' },
    'longitude'         => %new-result{ 'location' }{ 'longitude' },
    
    'postal_code' => %new-result{ 'postal' }{ 'code' },
    
    # regions are now returned as an optional array of subdivisions
    # for example first item may be voivodship, second item may be county, etc.
    # what you want is probably the most specific subdivision which is last item of the array.
    'region' => %new-result{ 'subdivisions' } ??
        %new-result{ 'subdivisions' }[ * - 1 ]{ 'names' }{ 'en' } !! Nil,
    'region_code' => %new-result{ 'subdivisions' } ??
        %new-result{ 'subdivisions' }[ * - 1 ]{ 'iso_code' } !! Nil,

    'time_zone' => %new-result{ 'location' }{ 'time_zone' }
```

## Check the new stuff

GeoIP2 gives new possibilities for City database:

* translated names
* is in European Union flag
* accuracy radius for latitude / longitude
* country that IP is registered in

But you are not limited to that. Unlike GeoIP v1, GeoIPv2 module is an universal reader for all MaxMind databases.

Check [this test](https://github.com/bbkr/GeoIP2/blob/master/t/01-products.t) to see what informations can be extracted from which database.

## Good luck!
