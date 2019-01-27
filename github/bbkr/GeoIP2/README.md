# MaxMind GeoIP v2 libraries reader

[![Build Status](https://travis-ci.org/bbkr/GeoIP2.svg?branch=master)](https://travis-ci.org/bbkr/GeoIP2)

Reader for [MaxMind databases](https://www.maxmind.com/en/geoip2-databases) including:
* Country
* City
* Anonymous IP
* ISP
* Domain
* Connection Type
* in any distribution form ( Lite, Pro, Enterprise )
* and any other database in [*.mmdb 2.0 format](https://github.com/maxmind/MaxMind-DB/blob/master/MaxMind-DB-spec.md)

## SYNOPSIS

```perl6
    use GeoIP2;
    
    my $geo = GeoIP2.new( path => '/home/me/Database.mmdb' );
    
    # lookup by IPv4
    say $geo.locate( ip => '8.8.8.8' );
    
    # lookup by IPv6
    say $geo.locate( ip => '2001:4860:4860:0:0:0:0:8888' );
    
    # show database information
    say $geo.build-timestamp;
    say $geo.ip-version;
    say $geo.languages;
    say $geo.description;
```

## METHODS

### new( path => '/home/me/Database.mmdb' )

Initialize database.

### locate( ip => '1.1.1.1' )

Return location data for given IP or `Nil` if IP is not found.

IP can be given as:
* IPv4 dotted decimal format - `8.8.8.8`
* IPv6 full format - `2001:4860:4860:0000:0000:0000:0000:8888`
* IPv6 without leading zeroes - `2001:4860:4860:0:0:0:0:8888`
* (IPv6 compressed format - `2001:4860:4860::8888` - is not yet supported)

Note that returned data structure is specific for opened databse type,
for example ISP database returns:

```perl6
GeoIP2.new( path => './GeoIP2-ISP.mmdb' ).locate( ip => '78.31.153.58' );

{
    'autonomous_system_number' => 29314,
    'autonomous_system_organization' => 'Vectra S.A.',
    'isp' => 'Jarsat Sp. z o.o.',
    'organization' => 'Jarsat Sp. z o.o.'
}
```

Sometimes returned values are localized, like in City database:

```perl6
GeoIP2.new( path => './GeoIP2-City.mmdb' ).locate( ip => '78.31.153.58' );

{
    'country' => {
        'geoname_id' => 798544,
        'names' => {
            'ru' => 'Польша',
            'es' => 'Polonia',
            'pt-BR' => 'Polônia',
            'zh-CN' => '波兰',
            'ja' => 'ポーランド共和国',
            'de' => 'Polen',
            'fr' => 'Pologne',
            'en' => 'Poland'
        },
        'iso_code' => 'PL',
        'is_in_european_union' => True
    },
    'city' => {
        'geoname_id' => 3099434,
        'names' => {
            'ru' => 'Гданьск',
            'es' => 'Gdansk',
            'pt-BR' => 'Gdańsk',
            'zh-CN' => '格但斯克',
            'ja' => 'グダニスク',
            'de' => 'Danzig',
            'fr' => 'Gdańsk',
            'en' => 'Gdańsk'
        }
    },
    'continent' => {
        'geoname_id' => 6255148,
        'names' => {
            'ru' => 'Европа',
            'es' => 'Europa',
            'pt-BR' => 'Europa',
            'zh-CN' => '欧洲',
            'ja' => 'ヨーロッパ',
            'de' => 'Europa',
            'fr' => 'Europe',
            'en' => 'Europe'
        },
    }
    'subdivisions' => [
        {
            'geoname_id' => 3337496,
            'iso_code' => 'PM',
            'names' => {
                'de' => 'Woiwodschaft Pommern',
                'en' => 'Pomerania',
                'es' => 'Pomerania',
                'fr' => 'Voïvodie de Poméranie',
                'ja' => 'ポモージェ県',
                'ru' => 'Поморское воеводство'
            }
        }
    ],
    ...
}
```

In such case list of available languages can be also checked through [languages](#languages) attribute.
If your language is not provided out-of-the-box please check [TRANSLATIONS](#translations) section.

## ATTRIBUTES

### build-timestamp

DateTime object representing time when database was compiled.

### ip-version

Version object representing largest supported IP type, for example `v6`.

### languages

Set object representing languages that location names are translated to.
Check [TRANSLATIONS](#translations) section if language that you need is not on the list.

### description / description( 'RU' )

String describing database kind, for example `GeoIP2 ISP database`.
Default is English but it may be requested in any of the [supported languages](#languages).

### binary-format-version / database-type / ipv4-start-node / node-byte-size / node-count / record-size / search-tree-size

Geeky stuff.

## FLAGS

### debug

Helpful for investigating IP loation and data decoding issues.
Can be passed in constructor or turned `True` / `False` at any time:

```perl6
my $geo = GeoIP2.new( path => '/home/me/Database.mmdb', :debug );
...
$geo.debug = False;
...
$geo.debug = True;
...
```

## REQUIREMENTS

This is Pure Perl module - C maxminddb library is not required.
Here is how to start with free GeoIP Lite libraries right away:

### MacOS

* Install [HomeBrew](https://brew.sh).

In terminal:

* Install tool to fetch databases - `brew install geoipupdate`.
* Fetch databases - `geoipupdate` (may take a while).

In code:

```perl6
my $geo = GeoIP2.new( path => '/usr/local/var/GeoIP/GeoLite2-City.mmdb' );
say $geo.locate( ip => '8.8.8.8' );
```

### Ubuntu Linux and derivatives

In terminal:

* Install tool to fetch databases - `sudo apt-get install geoipupdate`.
* Fetch databases - `sudo geoipupdate` (may take a while).

In code:

```perl6
my $geo = GeoIP2.new( path => '/var/lib/GeoIP/GeoLite2-City.mmdb' );
say $geo.locate( ip => '8.8.8.8' );
```

### Arch Linux and derivatives

In terminal:

* Install prepackaged databases - `pacman -Syu geoip2-database`.

In code:

```perl6
my $geo = GeoIP2.new( path => '/usr/share/GeoIP/GeoLite2-City.mmdb' );
say $geo.locate( ip => '8.8.8.8' );
```

Note that `geoipupdate` tool method is also possible,
but because Arch is a rolling release distro installing prepackaged databases
provides the same frequency of database updates as fetching direcltly from MaxMind.

## TRANSLATIONS

Some databases have built-in translations, however set of supported languages is rather limited.
Fortunately MaxMind provides additional translation data.

Download [this file](http://www.maxmind.com/GeoIPLocationCSV-localized.zip).
Inside ZIP there are few CSV files and README file with their description.

Now all you have to do is to find `geoname_id` field
returned by [locate()](#locate-ip--1111-) method in correspoding CSV file,
for example:

Country, second column is language code.
```
$ grep 798544 iso-3166-localized.csv
PL,ne,"पोल्याण्ड",798544
PL,ki,Polandi,798544
PL,tr,Polonya,798544
PL,da,Polen,798544
PL,my,"ပိုလန်",798544
PL,ug,"پولشا",798544
PL,gl,Polonia,798544
PL,ro,Polonia,798544
...
```

City, second column is language code.
```
$ grep 3099434 GeoIPCity-localized.csv
35601,ascii,Gdansk,3099434
35601,tr,Gdansk,3099434
35601,da,"Gdańsk",3099434
35601,gl,Gdansk,3099434
35601,ru,"Гданьск",3099434
35601,ro,"Gdańsk",3099434
35601,az,Qdansk,3099434
35601,co,Gdansk,3099434
...
```

Region (subdivision), third column is language code.
```
$ grep 3337496 region-code-localized.csv
PL,82,af,Pommere,3337496
PL,82,es,Pomerania,3337496
PL,82,da,Pomorskie,3337496
PL,82,ru,"Поморское воеводство",3337496
PL,82,csb,"Pòmòrsczé wòjewództwò",3337496
PL,82,fr,"Voïvodie de Poméranie",3337496
PL,82,ro,"Voievodatul Pomerania",3337496
PL,82,ja,"ポモージェ県",3337496
...
```

If you want to preload those translations into some database for easier access
you can use single database because geoname IDs are mutually exclusive between files.

For example to feed translations into Redis:
```
> HSET 798544 tr "Polonya"
> HSET 798544 ki "Polandi"
..
> HSET 3099434 tr "Gdansk"
> HSET 3099434 ru "Гданьск"
...
> HSET 3337496 ru "Поморское воеводство"
> HSET 3337496 csb "Pòmòrsczé wòjewództwò"
...
```

And to find translation of geoname ID to specific language:
```
> HGET 3099434 ru
"Гданьск"
```

## COPYRIGHTS

This third party reader is released under Artistic-2.0 license
and is based on [open source database spec](https://github.com/maxmind/MaxMind-DB) released under Creative Commons license.
Which means you can use it to read GeoIP2 free and paid databases both for personal and commercial use.

However keep in mind that MaxMind® and GeoIP® [are trademarks](https://www.maxmind.com/en/terms_of_use)
so if you want to fork this module do it [under your own authority](https://docs.perl6.org/language/typesystem#Versioning_and_Authorship)
to avoid confusion with their official libraries.
