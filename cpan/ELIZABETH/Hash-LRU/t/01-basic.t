use v6.c;
use Test;

use Hash::LRU;

plan 4 + 4 * 7;

is-deeply (my %h1 is LRU = a => 1), %h1,
  'did %h1 get initialized correctly';
is-deeply (my %h2 is LRU( elements => 100 ) = a => 1), %h2,
  'did %h2 get initialized correctly';
is-deeply (my %h3{Any} is LRU = a => 1), %h3,
  'did %h3 get initialized correctly';
is-deeply (my %h4{Any} is LRU( elements => 100 ) = a => 1), %h4,
  'did %h4 get initialized correctly';

for
  %h1, '%h is LRU',
  %h2, '%h is LRU( elements => 100 )',
  %h3, '%h{Any} is LRU',
  %h4, '%h{Any} is LRU( elements => 100 )'
-> %h, $what {
    ok %h<a>:exists, "does key 'a' exist for $what";
    is %h.elems, 1, 'does $what have only 1 element';
    %h{$_} = 1 for ^99;
    is %h.elems, 100, 'does $what have 100 elements';
    ok %h<a>:exists, "does key 'a' still exist for $what";
    %h{100} = 1;
    ok %h{100}:exists, "does key '100' exist for $what";
    is %h.elems, 100, 'does $what still have 100 elements';
    nok %h<a>:exists, "is key 'a' removed for $what";
}

# vim: ft=perl6 expandtab sw=4
