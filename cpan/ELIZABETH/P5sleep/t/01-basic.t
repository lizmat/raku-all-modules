use v6.c;
use Test;
use P5sleep;

plan 3;

ok defined(::('&sleep')),         'is &sleep imported?';
ok !defined(P5sleep::{'&sleep'}), 'is &sleep externally NOT accessible?';

is sleep(2), 2, 'did we sleep long enough';

# vim: ft=perl6 expandtab sw=4
