use v6.c;
use Test;
use P5lc;

plan 6;

is lc('FOO'), 'foo', 'did we get a good foo';
is lc('foo'), 'foo', 'did we get same foo';
is lc(''),       '', 'did we get a good empty string';

with "BAR" { is lc(), 'bar', 'did we get a good bar' }
with "bar" { is lc(), 'bar', 'did we get same bar' }
with ""    { is lc(), '',    'did we get a good empty string' }

# vim: ft=perl6 expandtab sw=4
