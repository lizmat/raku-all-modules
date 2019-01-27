use v6.c;
use Test;

use Adverb::Eject;

plan 12;

my @a = ^10;
is @a[1]:eject, Nil, 'did we get Nil from a single eject';
is +@a, 9, 'did the element get removed';
is @a, '0 2 3 4 5 6 7 8 9', 'did the right element get removed';

is @a[1,3,5,7]:eject, Nil, 'did we get Nil from a multi eject';
is +@a, 5, 'did the right number of elements get removed';
is @a, '0 3 5 7 9', 'did the right elements get removed';

my %h = "a" .. "j" Z=> ^10;
is %h<a>:eject, Nil, 'did we get Nil from a single eject';
is +%h, 9, 'did the element get removed';
is %h.keys.sort, 'b c d e f g h i j', 'did the right element get removed';

is %h<b d f h>:eject, Nil, 'did we get Nil from a multi eject';
is +%h, 5, 'did the right number of elements get removed';
is %h.keys.sort, 'c e g i j', 'did the right elements get removed';

# vim: ft=perl6 expandtab sw=4
