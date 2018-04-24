use v6.c;
use Test;
use List::UtilsBy <unzip_by>;

plan 5;

is-deeply unzip_by( { $_ } ), (), 'empty list';

is-deeply unzip_by( { @_ }, "a", "b", "c" ), [ ["a", "b", "c"], ],
  'identity function';

is-deeply unzip_by( { $_,$_ }, "a", "b", "c"), [ ["a","b","c"], ["a","b","c"] ],
  'clone function';

is-deeply unzip_by( { .comb }, "a1","b2","c3"), [ ["a","b","c"],["1","2","3"] ],
  'for each char';

is-deeply unzip_by( { .comb }, "a","b2","c"), [ ["a","b","c"],[Any,"2"] ],
  'for each char but uneven';

# vim: ft=perl6 expandtab sw=4
