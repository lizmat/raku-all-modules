#!/usr/bin/env perl6

use BitEnum;

my enum MyBits (
    A => 0x01,
    B => 0x02,
    C => 0x04,
    D => 0x08,
);

my $x = BitEnum[MyBits].new(6);

put $x;

put +$x;

say $x;

$x.set(A,B);

$x.clear(B);

say $x.isset(A,B);

$x.toggle(C);

.key.say for @$x;
