use v6.c;
use Test;
use List::UtilsBy <count_by>;

plan 6;

is-deeply count_by( -> $a { } ), {}, 'empty list';

is-deeply count_by( { $_ }, "a"), { a => 1 }, 'unit list';

is-deeply count_by( -> $_ is copy { my $ret = $_; $_ = 42; $ret }, "a"),
  { a => 1 },
  'localising $_';

is-deeply count_by( { "all" }, "a", "b"), { all => 2 },
  'constant function preserves order';

is-deeply count_by( { $_[0] }, "b", "a").sort(*.key),
  (a => 1, b => 1),
  'identity function on $_[0]' ;

is-deeply count_by( &chars, <a b cc dd eee>).sort(*.key),
  ("1" => 2, "2" => 2, "3" => 1),
  'chars function';

# vim: ft=perl6 expandtab sw=4
