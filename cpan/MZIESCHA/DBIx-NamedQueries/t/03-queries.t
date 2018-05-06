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

subtest 'create db subtests', {
    plan 2;

    isa-ok( $namedqueries, 'DBIx::NamedQueries', 'Instance isa DBIx::NamedQueries' );

    ok( $namedqueries.write('test/create'), 'Create table test' );
};

subtest 'insert subtests', {
    plan 2;

    ok(
        $namedqueries.write(
            'test/insert',
            {
                name        => 'user name',
                description => 'test description',
                quantity    => 123,
                price       => 123,
            }
        ),
        q~Insert 'user name' test~
    );

    ok(
        $namedqueries.write(
            'test/insert',
            {   name        => 'user',
                description => 'Developer',
                quantity    => 123,
                price       => 123,
            }
        ),
        q~Insert 'user' test~
    );
};

subtest 'select after insert subtests', {
    plan 2;

    is-deeply(
        $namedqueries.read( 'test/list', { description => 'Developer', } ),
        (   {   description => "Developer",
                id          => 2,
                name        => "user",
                price       => 123,
                quantity    => 123
            },
        ),
        'Read with params test'
    );

    my $got_results = $namedqueries.read('test/select');
    my $expect_results = (
       {
            description => "test description",
            id          => 1,
            name        => "user name",
            price       => 123,
            quantity    => 123
        },
        {
            description => "Developer",
            id          => 2,
            name        => "user",
            price       => 123,
            quantity    => 123
        },
    );

    is-deeply( $got_results, $expect_results, 'Read wihtout params test' );
};

subtest 'DBIx::NamedQueries delete db test', {
    plan 1;

    ok "test.sqlite3".IO.unlink, 'unlink test db';

};
