use lib 'lib';

use Test;
use GeoIP2;

plan 7;

# purpose of this test is to run reader
# against different databases currently offered by MaxMind

subtest 'anonymous IP' => sub {
    
    plan 3;
    
    my $geo = GeoIP2.new( path => './t/databases/GeoIP2-Anonymous-IP-Test.mmdb' );
    
    is $geo.database-type, 'GeoIP2-Anonymous-IP', 'database type';
    
    my %got = $geo.locate( ip => '81.2.69.0' );
    my %expected = (
        'is_hosting_provider' => True,
        'is_public_proxy' => True,
        'is_anonymous_vpn' => True,
        'is_tor_exit_node' => True,
        'is_anonymous' => True        
    );
    is-deeply %got, %expected, 'lookup by IPv4';
    
    %got = $geo.locate( ip => 'fec0:0:0:0:0:0:0:0' );
    %expected = ( );
    is-deeply %got, %expected, 'lookup by IPv6';
    
};

subtest 'city' => sub {
    
    plan 3;
    
    my $geo = GeoIP2.new( path => './t/databases/GeoIP2-City-Test.mmdb' );
    
    is $geo.database-type, 'GeoIP2-City', 'database type';
    
    my %got = $geo.locate( ip => '2.125.160.216' );
    my %expected = (
        'country' => {
            'geoname_id' => 2635167,
            'names' => {
                'ru' => 'Великобритания',
                'es' => 'Reino Unido',
                'pt-BR' => 'Reino Unido',
                'zh-CN' => '英国',
                'ja' => 'イギリス',
                'de' => 'Vereinigtes Königreich',
                'fr' => 'Royaume-Uni',
                'en' => 'United Kingdom'
            },
            'iso_code' => 'GB',
            'is_in_european_union' => True
        },
        'registered_country' => {
            'geoname_id' => 3017382,
            'names' => {
                'ru' => 'Франция',
                'es' => 'Francia',
                'pt-BR' => 'França',
                'zh-CN' => '法国',
                'ja' => 'フランス共和国',
                'de' => 'Frankreich',
                'fr' => 'France',
                'en' => 'France'
            },
            'iso_code' => 'FR',
            'is_in_european_union' => True
        },
        'city' => {
            'geoname_id' => 2655045,
            'names' => {
                'en' => 'Boxford'
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
            'code' => 'EU'
        },
        'location' => {
            'time_zone' => 'Europe/London',
            'longitude' => -1.25e0,
            'accuracy_radius' => 100,
            'latitude' => 51.75e0
        },
        'subdivisions' => [
            {
                'geoname_id' => 6269131,
                'names' => {
                    'es' => 'Inglaterra',
                    'pt-BR' => 'Inglaterra',
                    'fr' => 'Angleterre',
                    'en' => 'England'
                },
                'iso_code' => 'ENG'
            },
            {
                'geoname_id' => 3333217,
                'names' => {
                    'ru' => 'Западный Беркшир',
                    'zh-CN' => '西伯克郡',
                    'en' => 'West Berkshire'
                },
                'iso_code' => 'WBK'
            }
        ],
        'postal' => {
            'code' => 'OX1'
        }
    );
    is-deeply %got, %expected, 'lookup by IPv4';
    
    %got = $geo.locate( ip => '2a02:ffc0:0:0:0:0:0:0' );
    %expected = (
        'country' => {
            'geoname_id' => 2411586,
            'names' => {
                'ru' => 'Гибралтар',
                'es' => 'Gibraltar',
                'pt-BR' => 'Gibraltar',
                'ja' => 'ジブラルタル',
                'de' => 'Gibraltar',
                'fr' => 'Gibraltar',
                'en' => 'Gibraltar'
            },
            'iso_code' => 'GI'
        },
        'registered_country' => {
            'geoname_id' => 2411586,
            'names' => {
                'ru' => 'Гибралтар',
                'es' => 'Gibraltar',
                'pt-BR' => 'Gibraltar',
                'ja' => 'ジブラルタル',
                'de' => 'Gibraltar',
                'fr' => 'Gibraltar',
                'en' => 'Gibraltar'
            },
            'iso_code' => 'GI'
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
            'code' => 'EU'
        },
        'location' => {
            'time_zone' => 'Europe/Gibraltar',
            'longitude' => -5.35e0,
            'accuracy_radius' => 100,
            'latitude' => 36.13333e0
        }
    );
    is-deeply %got, %expected, 'lookup by IPv6';
    
};

subtest 'connection type' => sub {
    
    plan 3;
    
    my $geo = GeoIP2.new( path => './t/databases/GeoIP2-Connection-Type-Test.mmdb' );
    
    is $geo.database-type, 'GeoIP2-Connection-Type', 'database type';
    
    my %got = $geo.locate( ip => '1.0.0.0' );
    my %expected = (
        'connection_type' => 'Dialup',
    );
    is-deeply %got, %expected, 'lookup by IPv4';
    
    %got = $geo.locate( ip => '2003:0:0:0:0:0:0:0' );
    %expected = (
        'connection_type' => 'Cable/DSL',
    );
    is-deeply %got, %expected, 'lookup by IPv6';
    
};

subtest 'country' => sub {
    
    plan 3;
    
    my $geo = GeoIP2.new( path => './t/databases/GeoIP2-Country-Test.mmdb' );
    
    is $geo.database-type, 'GeoIP2-Country', 'database type';
    
    my %got = $geo.locate( ip => '2.125.160.216' );
    my %expected = (
        'country' => {
            'geoname_id' => 2635167,
            'names' => {
                'ru' => 'Великобритания',
                'es' => 'Reino Unido',
                'pt-BR' => 'Reino Unido',
                'zh-CN' => '英国',
                'ja' => 'イギリス',
                'de' => 'Vereinigtes Königreich',
                'fr' => 'Royaume-Uni',
                'en' => 'United Kingdom'
            },
            'iso_code' => 'GB',
            'is_in_european_union' => True
        },
        'registered_country' => {
            'geoname_id' => 3017382,
            'names' => {
                'ru' => 'Франция',
                'es' => 'Francia',
                'pt-BR' => 'França',
                'zh-CN' => '法国',
                'ja' => 'フランス共和国',
                'de' => 'Frankreich',
                'fr' => 'France',
                'en' => 'France'
            },
            'iso_code' => 'FR',
            'is_in_european_union' => True
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
            'code' => 'EU'
        },
        'postal' => {
            'code' => 'OX1'
        }
    );
    is-deeply %got, %expected, 'lookup by IPv4';
    
    %got = $geo.locate( ip => '2a02:ffc0:0:0:0:0:0:0' );
    %expected = (
        'country' => {
            'geoname_id' => 2411586,
            'names' => {
                'ru' => 'Гибралтар',
                'es' => 'Gibraltar',
                'pt-BR' => 'Gibraltar',
                'ja' => 'ジブラルタル',
                'de' => 'Gibraltar',
                'fr' => 'Gibraltar',
                'en' => 'Gibraltar'
            },
            'iso_code' => 'GI'
        },
        'registered_country' => {
            'geoname_id' => 2411586,
            'names' => {
                'ru' => 'Гибралтар',
                'es' => 'Gibraltar',
                'pt-BR' => 'Gibraltar',
                'ja' => 'ジブラルタル',
                'de' => 'Gibraltar',
                'fr' => 'Gibraltar',
                'en' => 'Gibraltar'
            },
            'iso_code' => 'GI'
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
            'code' => 'EU'
        }
    );
    is-deeply %got, %expected, 'lookup by IPv6';
    
};

subtest 'domain' => sub {
    
    plan 3;
    
    my $geo = GeoIP2.new( path => './t/databases/GeoIP2-Domain-Test.mmdb' );
    
    is $geo.database-type, 'GeoIP2-Domain', 'database type';
    
    my %got = $geo.locate( ip => '1.2.0.0' );
    my %expected = (
        'domain' => 'maxmind.com',
    );
    is-deeply %got, %expected, 'lookup by IPv4';
    
    %got = $geo.locate( ip => '2a02:8420:48f4:b000:0:0:0:0' );
    %expected = (
        'domain' => 'sfr.net',
    );
    is-deeply %got, %expected, 'lookup by IPv6';
    
};

subtest 'ISP' => sub {
    
    plan 3;
    
    my $geo = GeoIP2.new( path => './t/databases/GeoIP2-ISP-Test.mmdb' );
    
    is $geo.database-type, 'GeoIP2-ISP', 'database type';
    
    my %got = $geo.locate( ip => '1.128.0.0' );
    my %expected = (
        'autonomous_system_number' => 1221,
        'isp' => 'Telstra Internet',
        'autonomous_system_organization' => 'Telstra Pty Ltd',
        'organization' => 'Telstra Internet'
    );
    is-deeply %got, %expected, 'lookup by IPv4';
    
    %got = $geo.locate( ip => '2c0f:ff80:0:0:0:0:0:0' );
    %expected = (
        'autonomous_system_number' => 237,
        'autonomous_system_organization' => 'Merit Network Inc.',
    );
    is-deeply %got, %expected, 'lookup by IPv6';
    
};

subtest 'precision enterprise' => sub {
    
    plan 3;
    
    my $geo = GeoIP2.new( path => './t/databases/GeoIP2-Precision-Enterprise-Test.mmdb' );
    
    is $geo.database-type, 'GeoIP2-Precision-Enterprise', 'database type';
    
    my %got = $geo.locate( ip => '1.9.127.107' );
    my %expected = (
        'traits'  => {
             'user_type' => 'business'
        }
    );
    is-deeply %got, %expected, 'lookup by IPv4';
    
    %got = $geo.locate( ip => '2001:0:d06e:d971:0:0:0:0' );
    %expected = (
        'country' => {
            'geoname_id' => 6252001,
            'names' => {
                'ru' => 'США',
                'es' => 'Estados Unidos',
                'pt-BR' => 'Estados Unidos',
                'zh-CN' => '美国',
                'ja' => 'アメリカ合衆国',
                'de' => 'USA',
                'fr' => 'États-Unis',
                'en' => 'United States'
            },
            'iso_code' => 'US',
            'confidence' => 99
        },
        'registered_country' => {
            'geoname_id' => 6252001,
            'names' => {
                'ru' => 'США',
                'es' => 'Estados Unidos',
                'pt-BR' => 'Estados Unidos',
                'zh-CN' => '美国',
                'ja' => 'アメリカ合衆国',
                'de' => 'USA',
                'fr' => 'États-Unis',
                'en' => 'United States'
            },
            'iso_code' => 'US'
        },
        'city' => {
            'geoname_id' => 4734825,
            'names' => {
                'ru' => 'Шугар-Ленд',
                'pt-BR' => 'Sugar Land',
                'ja' => 'シュガーランド',
                'en' => 'Sugar Land'
            },
            'confidence' => 20
        },
        'continent' => {
            'geoname_id' => 6255149,
            'names' => {
                'ru' => 'Северная Америка',
                'es' => 'Norteamérica',
                'pt-BR' => 'América do Norte',
                'zh-CN' => '北美洲',
                'ja' => '北アメリカ',
                'de' => 'Nordamerika',
                'fr' => 'Amérique du Nord',
                'en' => 'North America'
            },
            'code' => 'NA'
        },
        'location' => {
            'metro_code' => 618,
            'time_zone' => 'America/Chicago',
            'longitude' => -95.635e0,
            'accuracy_radius' => 1000,
            'latitude' => 29.6197e0
        },
        'subdivisions' => [
            {
                'geoname_id' => 4736286,
                'names' => {
                    'ru' => 'Техас',
                    'es' => 'Texas',
                    'zh-CN' => '德克萨斯州',
                    'ja' => 'テキサス州',
                    'fr' => 'Texas',
                    'en' => 'Texas'
                },
                'iso_code' => 'TX',
                'confidence' => 60
            },
        ],
        'postal' => {
            'code' => '77487',
            'confidence' => 1
        },
        'traits' => {
            'connection_type' => 'Cable/DSL',
            'autonomous_system_organization' => 'Comcast Cable Communications, LLC',
            'user_type' => 'business',
            'organization' => 'Comcast Business',
            'autonomous_system_number' => 11025,
            'isp' => 'Comcast Business',
            'domain' => 'comcastbusiness.net'
        }
    );
    is-deeply %got, %expected, 'lookup by IPv6';
    
};
