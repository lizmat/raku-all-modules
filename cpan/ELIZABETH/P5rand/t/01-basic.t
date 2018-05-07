use v6.c;
use Test;
use P5rand;

plan 8;

ok defined(::('&rand')),         'is &rand imported?';
ok !defined(P5rand::{'&rand'}),  'is &rand externally NOT accessible?';
ok defined(::('&srand')),        'is &srand imported?';
ok !defined(P5rand::{'&srand'}), 'is &srand externally NOT accessible?';

ok 0 < rand      <  1, 'did we get a random number between 0 and 1';
ok 0 < &rand(42) < 42, 'did we get a random number between 0 and 42';

is srand(42), 42, 'does setting srand return the value';
is srand(),   42, 'does srand return the value';

# vim: ft=perl6 expandtab sw=4
