use v6.c;

use Test;

plan 4;

use DBIx::NamedQueries;

use lib 't/lib';

subtest 'create db test', {
    plan 2;
    my $namedqueries = DBIx::NamedQueries.new(
        namespace => 'Queries',
        handle    => {
            type     => 'DBIish',
            driver   => 'SQLite',
            database => 'test.sqlite3',
        },
    );

    isa-ok( $namedqueries, 'DBIx::NamedQueries', 'Instance isa DBIx::NamedQueries' );
    
    ok( $namedqueries.write( 'test/create' ), 'Create table test' );
};

subtest 'insert tests', {
    plan 2;

    my $namedqueries = DBIx::NamedQueries.new(
        namespace => 'Queries',
        handle    => {
            type     => 'DBIish',
            driver   => 'SQLite',
            database => 'test.sqlite3',
        },
    );

    ok( $namedqueries.write('test/insert' , {
            name         => 'user name',
            description  => 'test description',
            quantity     => 123,
            price        => 123,
        }
    ), 'Instance isa DBIx::NamedQueries' );

    ok( $namedqueries.write('test/insert' , {
            name         => 'user',
            description  => 'Developer',
            quantity     => 123,
            price        => 123,
        }
    ), 'Instance isa DBIx::NamedQueries' );
};

subtest 'select tests', {
    plan 2;

    my $namedqueries = DBIx::NamedQueries.new(
        namespace => 'Queries',
        handle    => {
            type     => 'DBIish',
            driver   => 'SQLite',
            database => 'test.sqlite3',
        },
    );

    is-deeply $namedqueries.read( 'test/list', { description  => 'Developer',} ), ({
        description => "Developer",
        id          => 2,
        name        =>"user",
        price       => 123,
        quantity    => 123
    },),
    'Instance isa DBIx::NamedQueries';

    is-deeply $namedqueries.read( 'test/select' ), ({
        description => "test description",
        id          => 1,
        name        =>"user name",
        price       => 123,
        quantity    => 123
    },
    {
        description => "Developer",
        id          => 2,
        name        =>"user",
        price       => 123,
        quantity    => 123
    },), 'Instance isa DBIx::NamedQueries';
};

subtest 'DBIx::NamedQueries delete db test', {
    plan 1;
    ok "test.sqlite3".IO.unlink, 'unlink test db';

};