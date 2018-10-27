use lib 'lib';

use Test;
use GeoIP2;

plan 9;

dies-ok { GeoIP2.new }, 'file path is required';

throws-like { GeoIP2.new( path => './t/databases/nonexistent.mmdb' ) }, X::PathInvalid,
    'file path does not exist';

throws-like { GeoIP2.new( path => './t/databases' ) }, X::PathInvalid,
    'file path is not directory';

throws-like { GeoIP2.new( path => './t/databases/empty.mmdb' ) }, X::MetaDataNotFound,
    'metadata not found';

my $geo;
lives-ok { $geo = GeoIP2.new( path => './t/databases/MaxMind-DB-test-decoder.mmdb' ) },
    'open "MaxMind DB Decoder Test" database';

subtest 'metadata' => sub {
    
    plan 13;
    
    is $geo.binary-format-version, v2.0, 'binary format version';
    is $geo.build-timestamp.Str, '2015-07-15T17:38:55Z', 'build timestamp';
    is $geo.database-type, 'MaxMind DB Decoder Test', 'database type';
    is $geo.description, 'MaxMind DB Decoder Test database - contains every MaxMind DB data type',
        'description in default language';
    is $geo.description( language => 'EN' ), 'MaxMind DB Decoder Test database - contains every MaxMind DB data type',
        'description in existing language';
    is $geo.description( language => 'XX' ), Any, 'description in missing language';
    is $geo.ip-version, v6, 'ip version';
    is $geo.ipv4-start-node, 96, 'IPv4 start node';
    is $geo.languages, [ 'EN' ], 'languages';
    is $geo.node-byte-size, 6, 'node byte size';
    is $geo.node-count, 395, 'node count';
    is $geo.record-size, 24, 'record size';
    is $geo.search-tree-size, 2370, 'search tree size';

}

subtest 'data types' => sub {

    plan 2;
    
    # proper expected values copied from
    # https://github.com/maxmind/MaxMind-DB-Reader-perl/blob/master/t/MaxMind/DB/Reader-decoder.t
    
    my %got = $geo.locate( ip => '0.0.0.0' );
    my %expected = (
        'array' => [ ],
        'boolean' => False,
        'bytes' => Buf.new,
        'double' => 0e0,
        'float' => 0e0,
        'int32' => 0,
        'map' => { },
        'uint128' => 0,
        'uint16' => 0,
        'uint32' => 0,
        'uint64' => 0,
        'utf8_string' => ''
    );
    is-deeply %got, %expected, 'empty or zero';
    
    %got = $geo.locate( ip => '1.1.1.0' );
    %expected = (
        'array' => [ 1, 2, 3 ],
        'boolean' => True,
        'bytes' => Buf[ uint8 ].new( 0x00, 0x00, 0x00, 0x2a ),
        'double' => 42.123456,
        'float' => 1.1,
        'int32' => -268435456,
        'map' => {
            'mapX' => {
                'arrayX' => [ 7, 8, 9 ],
                'utf8_stringX' => 'hello'
            },
        },
        'uint128' => 1329227995784915872903807060280344576,
        'uint16' => 100,
        'uint32' => 268435456,
        'uint64' => 1152921504606846976,
        'utf8_string' => 'unicode! ☯ - ♫'
    );
    # follow precision from original test
    %got{ 'double' } .= round( 0.000001 );
    %got{ 'float' } .= round( 0.1 );
    is-deeply %got, %expected, 'big and complex';

}

subtest 'record sizes' => sub {

    plan 6;

    for 24, 28, 32 -> $size {
    
        $geo = GeoIP2.new( path => './t/databases/MaxMind-DB-test-mixed-' ~ $size ~ '.mmdb' );
        
        is-deeply $geo.locate( ip => '1.1.1.1' ), { ip => '::1.1.1.1' },
            'locate IPv4 by ' ~ $size ~ ' bit pointer';
            
        is-deeply $geo.locate( ip => '2001:0:101:120:0:0:0:0' ), { ip => '::1.1.1.32' },
            'locate IPv6 by ' ~ $size ~ ' bit pointer';
    }
    
}

subtest 'location not found' => sub {

    plan 2;

    $geo = GeoIP2.new( path => './t/databases/MaxMind-DB-test-mixed-24.mmdb' );
        
    is-deeply $geo.locate( ip => '6.6.6.6' ), Nil,
        'locate IPv4';
    
    is-deeply $geo.locate( ip => '6:6:6:6:6:6:6:6' ), Nil,
        'locate IPv6';
    
}
