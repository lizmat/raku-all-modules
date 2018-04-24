use v6.c;
use Test;
use List::UtilsBy <partition_by>;

plan 7;

is-deeply partition_by( -> $a { } ), {}, 'empty list';

is-deeply partition_by( { $_ }, "a"), { a => ["a"] }, 'unit list';

is-deeply partition_by( -> $_ is copy { my $ret = $_; $_ = 42; $ret }, "a"),
  { a => ["a"] },
  'localising $_';

is-deeply partition_by( { "all" }, "a", "b"), { all => [<a b>] },
  'constant function preserves order';
is-deeply partition_by( { "all" }, "b", "a"), { all => [<b a>] },
  'constant function preserves order';

is-deeply partition_by( { $_[0] }, "b", "a").sort(*.key),
  (a => ["a"], b => ["b"]),
  'identity function on $_[0]' ;

is-deeply partition_by( &chars, <a b cc dd eee>).sort(*.key),
  ("1" => [<a b>], "2" => [<cc dd>], "3" => ["eee"]),
  'chars function';

# vim: ft=perl6 expandtab sw=4
