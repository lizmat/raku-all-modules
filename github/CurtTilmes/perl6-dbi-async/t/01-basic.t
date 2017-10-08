use v6;
use Test;

use DBI::Async;

plan 15;

ok my $db = DBI::Async.new('TestMock'), 'Create DBI::Async';

ok my $res = $db.query('mockdata');

is $res.sth.statement, 'mockdata', 'Statement';
is $res.column-names, <col1 col2 colN>, 'Columns';
is $res.column-types.perl, [Str, Str, Int].perl, 'Types';

is $res.rows, 2, 'Results';

is $res.row.join(','), 'a,b,1', 'first row';
is $res.row.join(','), 'd,e,2', 'second row';
nok $res.row, 'third row is empty';
ok $res.sth.Finished, 'Finished';

$res.finish;

is-deeply $db.query('mockdata').array,
          ['a', 'b', 1], 'Array';

is-deeply $db.query('mockdata').hash, 
          { col1 => 'a', col2 => 'b', 'colN' => 1 }, 'Hash';

is-deeply $db.query('mockdata').arrays, 
          ( ['a','b',1], ['d','e',2] ), 'Arrays';

is-deeply $db.query('mockdata').flatarray,
          ( 'a', 'b', 1, 'd', 'e', 2 ), 'Flat Array';

is-deeply $db.query('mockdata').hashes,
          ( { col1 => 'a', col2 => 'b', 'colN' => 1 },
            { col1 => 'd', col2 => 'e', 'colN' => 2 } ), 'Hashes';

done-testing;
