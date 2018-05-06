use v6.c;

use Test;

plan 2;

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

    isa-ok $namedqueries, 'DBIx::NamedQueries', 'Instance isa DBIx::NamedQueries';

    throws-like(
        { $namedqueries.write('failtest/create') },
        Exception,
        message => q~Type check failed in binding to parameter '$obj_query'; expected DBIx::NamedQueries::Query but got Queries::Write::Failtest (Queries::Write::Failt...)~
    );
};

subtest 'DBIx::NamedQueries delete db test', {
    plan 1;

    ok "test.sqlite3".IO.unlink, 'unlink test db';

};
