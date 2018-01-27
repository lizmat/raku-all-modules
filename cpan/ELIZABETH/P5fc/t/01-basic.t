use v6.c;
use Test;
use P5fc;

plan 8;

ok defined(::('&fc')),      'is &fc imported?';
ok !defined(P5fc::{'&fc'}), 'is &fc externally NOT accessible?';

is fc('FOO'), 'foo', 'did we get a good foo';
is fc('foo'), 'foo', 'did we get same foo';
is fc(''),       '', 'did we get a good empty string';

with "BAR" { is fc(), 'bar', 'did we get a good bar' }
with "bar" { is fc(), 'bar', 'did we get same bar' }
with ""    { is fc(), '',    'did we get a good empty string' }

# vim: ft=perl6 expandtab sw=4
