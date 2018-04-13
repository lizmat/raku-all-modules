use v6.c;
use Test;
use P5hex;

plan 4;

ok defined(::('&hex')),       'is &hex imported?';
ok !defined(P5hex::{'&hex'}), 'is &hex externally NOT accessible?';
ok defined(::('&oct')),       'is &oct imported?';
ok !defined(P5hex::{'&oct'}), 'is &oct externally NOT accessible?';

# vim: ft=perl6 expandtab sw=4
