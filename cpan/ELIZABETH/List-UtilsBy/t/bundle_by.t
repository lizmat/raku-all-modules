use v6.c;
use Test;
use List::UtilsBy <bundle_by>;

plan 6;

is-deeply bundle_by( { @_[0] }, 1, (1, 2, 3)), (1, 2, 3),
  'bundle_by 1';

is-deeply bundle_by( { @_[0] }, 2, 1, 2, 3, 4), (1, 3),
  'bundle_by 2 first';

is-deeply bundle_by( { |@_ }, 2, (1, 2, 3, 4)), (1, 2, 3, 4),
  'bundle_by 2 all';
is-deeply bundle_by( { @_ }, 2, (1, 2, 3, 4)), ([1, 2], [3, 4]),
  'bundle_by 2 [all]';

is-deeply bundle_by( -> $a, $b { uc($b) => $a }, 2, <a b c d>),
  (B => "a", D => "c"),
  'bundle_by 2 constructing list of pairs';

is-deeply bundle_by( { @_ }, 2, 1, 2, 3), ([1, 2], [3]),
  'bundle_by 2 yields short final bundle';

# vim: ft=perl6 expandtab sw=4
