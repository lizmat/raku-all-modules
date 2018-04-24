use v6.c;
use Test;
use List::UtilsBy <zip_by>;

plan 7;

is-deeply zip_by( { $_ } ), (), 'empty list';

is-deeply zip_by( { |@_ }, ["a"], ["b"], ["c"] ), [ ("a", "b", "c") ],
  'singleton lists';

is-deeply zip_by( { |@_ }, "a", "b", "c"), ["a","b","c"], 'narrow lists';

is-deeply zip_by( { @_ }, ["a1","a2"],["b1","b2"]), [ ["a1","b1"],["a2","b2"] ],
  'zip with []';

is-deeply zip_by({ @_.join(",") }, ["a1","a2"], ["b1","b2"]), ["a1,b1","a2,b2"],
  'zip with join()';

is-deeply zip_by( { @_ }, [1..3], [1..2] ), [ [1,1], [2,2], [3,Any] ],
  'non-rectangular adds Any';

is-deeply zip_by( { |@_ }, [<one two three>], [1,2,3] ),
  ["one",1, "two",2, "three",3],
  'itemfunc can return lists';

# vim: ft=perl6 expandtab sw=4
