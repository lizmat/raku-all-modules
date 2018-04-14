use v6.c;

use Test;

plan 2;

use DBIx::NamedQueries::Handles;
use DBIx::NamedQueries::Handle::DBIish;

subtest 'DBIish handle tests', {
    plan 3;

    my $dbiish = DBIx::NamedQueries::Handle::DBIish.new;

    isa-ok(
        $dbiish, 'DBIx::NamedQueries::Handle::DBIish',
        'Instance isa DBIx::NamedQueries::Handle::DBIish'
    );

    isa-ok(
        $dbiish.connect( 'SQLite', 'test.sqlite3' ), 'DBDish::SQLite::Connection',
        'Instance isa DBDish::SQLite::Connection'
    );

    ok "test.sqlite3".IO.unlink, 'unlink test db';
};


subtest 'Tests of handles class', {
    plan 4;
    
    my $handles = DBIx::NamedQueries::Handles.new;

    isa-ok(
        $handles, 'DBIx::NamedQueries::Handles',
        'Instance isa DBIx::NamedQueries::Handles'
    );

    $handles.add_read_write('DBIish', 'SQLite', 'test.sqlite3' );
    isa-ok(
        $handles.read_write(), 'DBDish::SQLite::Connection',
        'Instance isa DBDish::SQLite::Connection'
    );

    $handles.add_read_only('DBIish', 'SQLite', 'test.sqlite3' );
    isa-ok(
        $handles.maybe_read_only(), 'DBDish::SQLite::Connection',
        'Instance isa DBDish::SQLite::Connection'
    );

    ok "test.sqlite3".IO.unlink, 'unlink test db';
};
