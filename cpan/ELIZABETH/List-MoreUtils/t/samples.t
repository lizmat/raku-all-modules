use v6.c;

use List::MoreUtils <samples>;
use Test;

plan 6;

{
    my @l = 1 .. 100;
    my @s = samples 10, @l;
    is +@s, 10, "samples stops correctly after 10 integer probes";
    my @u = @s.unique;
    is +@u, 10, "samples doesn't add any integer twice";
}

{
    my @l = 1 .. 10;
    my @s = samples 10, @l;
    is +@s, 10, "samples delivers 10 out of 10 when used as shuffle";
    my @u = @s.grep( *.defined ).unique;
    is +@u, 10, "samples doesn't add any integer twice";
}

{
    my @l = 'AA' .. 'ZZ';
    my @s = samples 10, @l;
    is +@s, 10, "samples stops correctly after 10 strings probes";
    my @u = @s.unique;
    is +@u, 10, "samples doesn't add any string twice";
}

# vim: ft=perl6 expandtab sw=4
