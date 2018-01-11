use v6.c;

use List::Util <shuffle>;

use Test;

plan 7;

ok defined(&shuffle), 'shuffle defined';

my @r = shuffle();
ok !@r,    'no args';

@r = shuffle(9);
is +@r, 1,' 1 in 1 out';
is @r[0], 9, 'one arg';

my @in = 1..100;
@r = shuffle(@in);
is +@r, +@in, 'elem count';
isnt "@r[]", "@in[]", 'result different to args';

my @s = sort @r;
is "@in[]", "@s[]", 'values';

# vim: ft=perl6 expandtab sw=4
