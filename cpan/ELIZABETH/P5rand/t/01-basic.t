use v6.c;
use Test;
use P5rand;

plan 4;

ok defined(::('&rand')),         'is &rand imported?';
ok !defined(P5rand::{'&rand'}),  'is &rand externally NOT accessible?';

ok 0 < rand      <  1, 'did we get a random number between 0 and 1';
ok 0 < &rand(42) < 42, 'did we get a random number between 0 and 42';

# vim: ft=perl6 expandtab sw=4
