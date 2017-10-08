#!/usr/bin/env perl6

use DBI::Async;

my $db = DBI::Async.new('Pg');

my $result = $db.query("select version()");
say $result.row[0];
$result.finish;

say $db.query("select version()").array[0];  # array() auto-finishes

my $promise = $db.query("select version()", :async);

await $promise.then(-> $p
{
    say $p.result.array[0];
});
