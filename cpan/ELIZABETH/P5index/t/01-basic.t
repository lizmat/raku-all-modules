use v6.c;
use Test;
use P5index;

plan 4;

ok defined(::('&index')),          'is &index imported?';
ok !defined(P5index::{'&index'}),  'is &index externally NOT accessible?';
ok defined(::('&rindex')),         'is &rindex imported?';
ok !defined(P5index::{'&rindex'}), 'is &rindex externally NOT accessible?';

# vim: ft=perl6 expandtab sw=4
