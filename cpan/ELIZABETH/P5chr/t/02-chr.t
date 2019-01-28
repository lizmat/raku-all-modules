use v6.c;
use Test;
use P5chr;

plan 516;

is chr(65), "A", 'did we get the right char';
is chr(-2), "�", 'did we get the replacement char';

with 65 { is chr(), "A", 'did we get the right char' }
with -2 { is chr(), "�", 'did we get the replacement char' }

for 128 .. 255 {
    is chr($_), '?',    'did we get a ? explicitely';
    is chr($_).ord, $_, 'did we get the number back with ord explicitely';
    is chr(), '?',    'did we get a ? implicitely';
    is chr().ord, $_, 'did we get the number back with ord implicitely';
}

# vim: ft=perl6 expandtab sw=4
