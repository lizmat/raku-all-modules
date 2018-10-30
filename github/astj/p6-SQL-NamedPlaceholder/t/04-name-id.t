use v6;
use Test;

use SQL::NamedPlaceholder;

my ($sql, $bind) = bind-named(q{ UPDATE foo SET a = '2016-02-02 00:00:00' }, { });
is $sql, q{ UPDATE foo SET a = '2016-02-02 00:00:00' };

done-testing;
