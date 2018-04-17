use v6.c;

use List::MoreUtils <mesh zip>;
use Test;

plan 4;

ok &mesh =:= &zip, 'is zip the same as mesh';

{
    my @x = <a b c d>;
    my @y = <1 2 3 4>;
    my @z = mesh @x, @y;
    is-deeply @z, [<a 1 b 2 c 3 d 4>], "mesh two list with same count of elements";
}

{
    my @a = 'x';
    my @b = 1,2;
    my @c = <zip zap zot>;
    my @z = mesh @a, @b, @c;
    is-deeply @z, ['x',1,'zip',Any,2,'zap',Any,Any,'zot'],
      "mesh three list with increasing count of elements";
}

# Make array with holes
{
    my @a = 1 .. 10;
    my @d; 
    my @z = mesh @a, @d;
    is-deeply @z,
        [1,Any,2,Any,3,Any,4,Any,5,Any,6,Any,7,Any,8,Any,9,Any,10,Any],
        "mesh one list with an empty list";
}

# vim: ft=perl6 expandtab sw=4
