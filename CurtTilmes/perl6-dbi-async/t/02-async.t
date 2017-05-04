use v6;
use Test;

use DBI::Async;

plan 4;

ok my $db = DBI::Async.new('TestMock'), 'Create DBI::Async';

my $p = $db.query('mockdata', :async);

ok $p ~~ Promise, 'Promise';

ok my $res = $p.result, 'Got result';

is-deeply $res.hashes,
          ( { col1 => 'a', col2 => 'b', 'colN' => 1 },
            { col1 => 'd', col2 => 'e', 'colN' => 2 } ), 'Hashes';

done-testing;
