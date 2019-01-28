use v6.c;
use Test;
use P5lc;

plan 6;

is uc('foo'), 'FOO', 'did we get a good FOO';
is uc('FOO'), 'FOO', 'did we get same FOO';
is uc(''),       '', 'did we get a good empty string';

with "bar" { is uc(), 'BAR', 'did we get a good BAR' }
with "BAR" { is uc(), 'BAR', 'did we get same BAR' }
with ""    { is uc(), '',    'did we get a good empty string' }

# vim: ft=perl6 expandtab sw=4
