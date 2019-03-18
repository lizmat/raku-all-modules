#!/usr/bin/env perl6

use BitEnum;

my enum MyBits (
    A => 0x01,
    B => 0x02,
    C => 0x04,
    D => 0x08,
    AB => 0x03,
    BC => 0x06,

);

my $x = BitEnum[MyBits].new(6);

say $x;

$x.set(AB, C);

say $x;

