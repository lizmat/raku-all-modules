use v6.c;
use Test;
use List::UtilsBy <uniq_by>;

plan 7;

is-deeply uniq_by( -> $a { } ), (), 'empty list';

is-deeply uniq_by( { $_ }, "a"), ("a",), 'unit list';

is-deeply uniq_by( -> $_ is copy { my $ret = $_; $_ = 42; $ret }, "a"), ("a",),
  'localising $_';

is-deeply uniq_by( { $_ }, "a", "b"), <a b>, 'identity function no-op';

is-deeply uniq_by( { $_ }, "b", "a"), <b a>, 'identity function on $_';

is-deeply uniq_by( { $_[0] }, "b", "a"), <b a>, 'identity function on $_[0]' ;

is-deeply uniq_by( &chars, <a b cc dd eee>), <a cc eee>, 'chars function';

# vim: ft=perl6 expandtab sw=4
