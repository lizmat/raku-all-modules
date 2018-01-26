use v6.c;
use Test;
use P5length;

plan 5;

ok defined(::('&length')),          'is &length imported?';
ok !defined(P5length::{'&length'}), 'is &length externally NOT accessible?';

is length("foobar"), 6, 'did we get the right length';
with "foobar" { is length, 6, 'did we get the right length implicitely' }
is-deeply length(Str), Str, 'did we get the right type object';

# vim: ft=perl6 expandtab sw=4
