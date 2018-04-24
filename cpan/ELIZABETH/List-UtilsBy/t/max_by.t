use v6.c;
use Test;
use List::UtilsBy <max_by nmax_by>;

plan 9;

is-deeply max_by( { $_ } ), [], 'empty list yields empty';

is-deeply max_by( { $_ }, 10, :scalar), 10,
  'unit list yields value in scalar context';
is-deeply max_by( { $_ }, 10), [10],
  'unit list yields unit list value';

is-deeply max_by( { $_ }, 10, 20, :scalar), 20, 'identity function on $_';
is-deeply max_by( { $_[0] }, 10, 20, :scalar), 20, 'identity function on $_[0]';

is-deeply max_by( &chars, <a ccc bb>, :scalar), "ccc", 'chars function';

is-deeply max_by( &chars, <a ccc bb ddd>, :scalar ), "ccc",
  'ties yield first in scalar context';
is-deeply max_by( &chars, <a ccc bb ddd>), [<ccc ddd>],
  'ties yield all maximal in list context';

is-deeply nmax_by( { $_ }, 10, 20, :scalar), 20, 'nmax_by alias';

# vim: ft=perl6 expandtab sw=4
