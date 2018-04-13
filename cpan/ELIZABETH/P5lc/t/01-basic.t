use v6.c;
use Test;
use P5lc;

plan 4;

ok defined(::('&lc')),      'is &lc imported?';
ok !defined(P5lc::{'&lc'}), 'is &lc externally NOT accessible?';
ok defined(::('&uc')),      'is &uc imported?';
ok !defined(P5lc::{'&uc'}), 'is &uc externally NOT accessible?';

# vim: ft=perl6 expandtab sw=4
