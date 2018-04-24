use v6.c;
use Test;
use List::UtilsBy <nsort_by rev_nsort_by>;

plan 9;

is-deeply nsort_by( -> $a { } ), (), 'empty list';

is-deeply nsort_by( { $_ }, 1), (1,), 'unit list';

is-deeply nsort_by( -> $_ is copy { my $ret = $_; $_ = 42; $ret }, 10), (10,),
  'localising $_';

is-deeply nsort_by( { $_ }, 20, 25), (20,25), 'identity function no-op';

is-deeply nsort_by( { $_ }, 25, 20), (20,25), 'identity function on $_';

is-deeply nsort_by( { $_[0] }, 25, 20), (20,25), 'identity function on $_[0]' ;

# list reverse on a single element is a no-op; scalar reverse will swap the
# characters. This test also ensures the correct context is seen by the function
is-deeply nsort_by( *.chars, <a bbb cc>), <a cc bbb>, 'chars function';

is-deeply nsort_by( +*.comb("a"), <apple hello armageddon>),
  <hello apple armageddon>, 'sort on number of a';

is-deeply rev_nsort_by( *.chars, <a bbb cc>), <bbb cc a>,
  'reverse chars function';

# vim: ft=perl6 expandtab sw=4
