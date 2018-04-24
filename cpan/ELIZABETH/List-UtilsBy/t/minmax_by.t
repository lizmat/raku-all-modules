use v6.c;
use Test;
use List::UtilsBy <minmax_by nminmax_by>;

plan 7;

is-deeply minmax_by( { $_ } ), (), 'empty list yields empty';

is-deeply minmax_by( { $_ }, 10), (10,10), 'unit list yields value twice';

is-deeply minmax_by( { $_ }, 10,20,30,40,50), (10,50),
  'identity function on $_';
is-deeply minmax_by( { $_[0] }, 10,20,30,40,50), (10,50),
  'identity function on $_[0]';

is-deeply minmax_by( { $_ }, 50,40,30,20,10), (10,50),
  'identity function on reversed input';

is-deeply minmax_by( &chars, <a ccc bb>), <a ccc>, 'chars function';

is-deeply nminmax_by( { $_ }, 10, 20), (10,20), 'nminmax_by alias';

# vim: ft=perl6 expandtab sw=4
