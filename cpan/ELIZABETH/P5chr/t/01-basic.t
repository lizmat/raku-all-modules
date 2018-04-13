use v6.c;
use Test;
use P5chr;

plan 4;

ok defined(::('&chr')),       'is &chr imported?';
ok !defined(P5chr::{'&chr'}), 'is &chr externally NOT accessible?';
ok defined(::('&ord')),       'is &ord imported?';
ok !defined(P5chr::{'&ord'}), 'is &ord externally NOT accessible?';

# vim: ft=perl6 expandtab sw=4
