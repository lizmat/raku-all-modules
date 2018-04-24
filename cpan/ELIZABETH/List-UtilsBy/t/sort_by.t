use v6.c;
use Test;
use List::UtilsBy <sort_by rev_sort_by>;

plan 8;

is-deeply sort_by( -> $a { } ), (), 'empty list';

is-deeply sort_by( { $_ }, "a"), ("a",), 'unit list';

is-deeply sort_by( -> $_ is copy { my $ret = $_; $_ = 42; $ret }, "a"), ("a",),
  'localising $_';

is-deeply sort_by( { $_ }, "a", "b"), <a b>, 'identity function no-op';

is-deeply sort_by( { $_ }, "b", "a"), <a b>, 'identity function on $_';

is-deeply sort_by( { $_[0] }, "b", "a"), <a b>, 'identity function on $_[0]' ;

# list reverse on a single element is a no-op; scalar reverse will swap the
# characters. This test also ensures the correct context is seen by the function
is-deeply sort_by( *.flip, "az", "by"), <by az>, 'flip function';

is-deeply rev_sort_by( { $_ }, "b", "a"), <b a>,
  'reverse sort identity function on $_';

# vim: ft=perl6 expandtab sw=4
