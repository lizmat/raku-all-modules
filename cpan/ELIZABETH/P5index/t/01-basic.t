use v6.c;
use Test;
use P5index;

plan 7;

ok defined(::('&index')),         'is &index imported?';
ok !defined(P5index::{'&index'}), 'is &index externally NOT accessible?';

is index("foobar","bar"),    3, 'did we find bar';
is index("foobar","bar",-1), 3, 'did we find bar before beginning';
is index("foofoo","bar"),   -1, 'did we *not* find bar';
is index("foofoo","foo",1),  3, 'did we find the second foo';
is index("foofoo","foo",9), -1, 'did we *not* find foo after end';

# vim: ft=perl6 expandtab sw=4
