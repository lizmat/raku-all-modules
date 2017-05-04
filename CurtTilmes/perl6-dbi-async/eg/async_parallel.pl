#!/usr/bin/env perl6

use DBI::Async;

my $db = DBI::Async.new('Pg', connections => 10);

await do for 1..100
{
    say "starting $_";
    $db.query("select pg_sleep(1)::text, ?::int as val", $_, :async).then(
              -> $p { say "Done #", $p.result.array[1] });
}

say "done";
