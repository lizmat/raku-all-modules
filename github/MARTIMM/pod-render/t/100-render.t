use v6.c;

use Test;
use lib 't';
use T100Render;

my T100Render::A $a .= new;
isa-ok $a, T100Render::A;
is $a.return-ah, 'aahhh', 'aahhh';


done-testing;
