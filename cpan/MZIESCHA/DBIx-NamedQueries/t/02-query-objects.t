use v6.c;

use Test;

plan 4;

use DBIx::NamedQueries;

use lib 't/lib';

my $namedqueries = DBIx::NamedQueries.new(
    namespace => 'Queries',
    handle    => {
        type     => 'DBIish',
        driver   => 'SQLite',
        database => 'test.sqlite3',
    },
);

isa-ok( $namedqueries, 'DBIx::NamedQueries', 'Instance isa DBIx::NamedQueries' );

subtest 'write query subtests', {
    plan 6;

    my $s_object_as_string = 'Queries::Write::Test';
    my $o_query = $namedqueries.object_from_string($s_object_as_string);
    isa-ok(
        $o_query,
        $s_object_as_string,
        'Instance isa ' ~ $s_object_as_string
    );
    
    does-ok $o_query, DBIx::NamedQueries::Write, 'Queries::Write::Test can write';
    
    can-ok( $o_query, 'alter', 'Instance can alter' );

    can-ok( $o_query, 'create', 'Instance can create' );

    can-ok( $o_query, 'insert', 'Instance can insert' );

    can-ok( $o_query, 'update', 'Instance can update' );

};

subtest 'read query subtests', {
    plan 5;

    my $s_object_as_string = 'Queries::Read::Test';
    my $o_query = $namedqueries.object_from_string($s_object_as_string);
    isa-ok(
        $o_query,
        $s_object_as_string,
        'Instance isa ' ~ $s_object_as_string
    );

    does-ok $o_query, DBIx::NamedQueries::Read, 'Queries::Read::Test can read';

    can-ok( $o_query, 'select', 'Instance can select' );

    can-ok( $o_query, 'list', 'Instance can list' );

    can-ok( $o_query, 'find', 'Instance can find' );

};

ok "test.sqlite3".IO.unlink, 'unlink test db';
