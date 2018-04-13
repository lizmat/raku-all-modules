use v6.c;
use Test;
use P5chr;

plan 4;

is ord('A'),   65, 'did we get the right number from single';
is ord('ABC'), 65, 'did we get the right number from multiple';

with 'A'   { is ord(), 65, 'did we get the right number from single' }
with 'ABC' { is ord(), 65, 'did we get the right number from multiple' }

# vim: ft=perl6 expandtab sw=4
