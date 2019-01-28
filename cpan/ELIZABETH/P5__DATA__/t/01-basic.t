use v6.c;
use Test;
use P5__DATA__;

plan 2;

ok defined(::('&DATA')),            'is DATA imported?';
ok !defined(P5__DATA__::{'&DATA'}), 'is DATA externally NOT accessible?';

# vim: ft=perl6 expandtab sw=4
