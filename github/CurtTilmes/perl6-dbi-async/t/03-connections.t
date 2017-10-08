use v6;
use Test;

use DBI::Async;

plan 11;

# Make two database handles

ok my $db = DBI::Async.new('TestMock', connections => 2), 'Create DBI::Async';

my $p = $db.query('mockdata', :async);

ok $p ~~ Promise, 'Promise';

# A simple query quickly goes through

await Promise.anyof(Promise.in(1), $p);

is $p.status, 'Kept', 'Query succeeded';

is-deeply $p.result.hashes,
          ( { col1 => 'a', col2 => 'b', 'colN' => 1 },
            { col1 => 'd', col2 => 'e', 'colN' => 2 } ), 'Check';

# Use both handles

ok my $res1 = $db.query('mockdata'), 'Query 1';

ok my $res2 = $db.query('mockdata'), 'Query 2';

# Try a third query

$p = $db.query('mockdata', :async);

ok $p ~~ Promise, 'Promise';

# It times out

await Promise.anyof(Promise.in(1), $p);

is $p.status, 'Planned', 'Query not run yet';

# Finish another query

is-deeply $res1.hashes,
          ( { col1 => 'a', col2 => 'b', 'colN' => 1 },
            { col1 => 'd', col2 => 'e', 'colN' => 2 } ), 'Check';

# Now the query goes through

await Promise.anyof(Promise.in(1), $p);

is $p.status, 'Kept', 'Delayed query run';

is-deeply $p.result.hashes,
          ( { col1 => 'a', col2 => 'b', 'colN' => 1 },
            { col1 => 'd', col2 => 'e', 'colN' => 2 } ), 'Check';

done-testing;
