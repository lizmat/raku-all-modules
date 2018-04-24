use v6.c;
use Test;
use List::UtilsBy <min_by nmin_by>;

plan 9;

is-deeply min_by( { $_ } ), [], 'empty list yields empty';

is-deeply min_by( { $_ }, 10, :scalar), 10,
  'unit list yields value in scalar context';
is-deeply min_by( { $_ }, 10), [10],
  'unit list yields unit list value';

is-deeply min_by( { $_ }, 10, 20, :scalar), 10, 'identity function on $_';
is-deeply min_by( { $_[0] }, 10, 20, :scalar), 10, 'identity function on $_[0]';

is-deeply min_by( &chars, <a ccc bb>, :scalar), "a", 'chars function';

is-deeply min_by( &chars, <a ccc bb ddd e>, :scalar ), "a",
  'ties yield first in scalar context';
is-deeply min_by( &chars, <a ccc bb ddd e>), [<a e>],
  'ties yield all minimal in list context';

is-deeply nmin_by( { $_ }, 10, 20, :scalar), 10, 'nmin_by alias';

# vim: ft=perl6 expandtab sw=4
