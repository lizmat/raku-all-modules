use Test;
use Xoo::DSN;
plan 7; # really need more than this

my @strs = (
  'mysql://john:pass@localhost:3306/my_db',
  'pg://127.0.0.1:8080/db',
  'sqlite://xyz.sqlite3',
  'does not compute',
  'oracle:/typo/db',
  'pg://john:doe:@127.0.0.1:8080/db',
  'pg://john:do@e:@127.0.0.1:8080/db',
  'oracle://typo/db',
);

my @exp = (
  { driver => 'mysql',  user => 'john', pass => 'pass', host => 'localhost',   port => 3306, db => 'my_db', },
  { driver => 'pg',     user => Nil,    pass => Nil,    host => '127.0.0.1',   port => 8080, db => 'db',    },
  { driver => 'sqlite', user => Nil,    pass => Nil,    host => 'xyz.sqlite3', port => Nil,  db => Nil,     },
  Nil|Any,
  Nil|Any,
  { driver => 'pg',     user => 'john', pass => 'doe:', host => '127.0.0.1',   port => 8080, db => 'db',    },
  Nil|Any,
  { driver => 'oracle', user => Nil,    pass => Nil,    host => 'typo',        port => Nil,  db => 'db',    },
);

for 0..@strs.elems-1 -> $x {
  is-deeply parse-dsn(@strs[$x]), @exp[$x], (Nil|Any ~~ @exp[$x] ?? 'fail' !! 'pass') ~ ': ' ~ @strs[$x];
}
