use v6.c;
use Test;
use P5ucfirst;

plan 10;

ok defined(::('&ucfirst')),           'is &ucfirst imported?';
ok !defined(P5ucfirst::{'&ucfirst'}), 'is &ucfirst externally NOT accessible?';

is ucfirst('foo'), 'Foo', 'did we get a good Foo';
is ucfirst('FOO'), 'FOO', 'did we get a good FOO';
is ucfirst('f'),   'F',   'did we get a good F';
is ucfirst(''),    '',    'did we get a good empty string';

with "bar" { is ucfirst, 'Bar', 'did we get a good Bar' }
with "BAR" { is ucfirst, 'BAR', 'did we get a good BAR' }
with "b"   { is ucfirst, 'B',   'did we get a good B' }
with ""    { is ucfirst, '',    'did we get a good empty string' }

# vim: ft=perl6 expandtab sw=4
