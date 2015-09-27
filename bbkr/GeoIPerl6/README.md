#Warning

This module works with legacy databases and legacy libgeoip C library.
New GeoIP2 can be accessed through libmaxminddb library that is quite different and I cannot give any timeline when updated version of module will be available.


#GeoIP City

Connect to [MaxMind](http://www.maxmind.com/en/home) GeoIP City databases.

Compatible with Perl 6 [Rakudo](http://rakudo.org/) 2013.02+,

##REQUIREMENTS

####Ubuntu Linux

* In terminal enter `sudo apt-get install libgeoip1 geoip-database-contrib`

####Mac OS X

* Install [MacPorts](http://www.macports.org/).
* In terminal enter `sudo port install libgeoip GeoLiteCity`.
* Add `DYLD_LIBRARY_PATH=/opt/local/lib` to your `~/.profile` and relog.

####Microsoft Windows

?

####Other systems

* Follow [installation instructions](http://www.maxmind.com/en/installation?city=1) from MaxMind.

##USAGE

```perl
    use GeoIP::City;
    
    my $geo = GeoIP::City.new;
    
    say $geo.locate( 'perl.org' );
    say $geo.locate( '207.171.7.63' );
```

In both cases it should print following Hash:

```perl
    {
        "area_code" => 310,
        "city" => "Beverly Hills",
        "continent_code" => "NA",
        "country" => "United States",
        "country_code" => "US",
        "dma_code" => 803,
        "latitude" => "34.074902",
        "longitude" => "-118.399696",
        "postal_code" => "90209",
        "region" => "California",
        "region_code" => "CA",
        "time_zone" => "America/Los_Angeles"
    }
```

Precision of response and amount of its fields may vary.

`Nil` is returned if location is not found.

###Paid databases

If you own [paid database](http://www.maxmind.com/en/city) you can provide its location.

```perl
    my $geo = GeoIP::City.new( '/Users/bbkr/GeoIPCity.dat' );
```

###Info

You can get version and date of used database.

```perl
    say $geo.info;
```

Will print.

```
    GEO-533LITE 20110501 Build 1 Copyright (c) 2011 MaxMind Inc All Rights Reserved
```

## LICENSE

Released under [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

## CONTACT

You can find me (and many awesome people who helped me to develop this module)
on irc.freenode.net #perl6 channel as **bbkr**.
