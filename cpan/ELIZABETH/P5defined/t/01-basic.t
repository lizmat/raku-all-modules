use v6.c;
use Test;
use P5defined;

plan 15;

ok defined(::('&defined')),           'is &defined imported?';
ok !defined(P5defined::{'&defined'}), 'is &defined externally NOT accessible?';
ok defined(::('&undef')),             'is &undef imported?';
ok !defined(P5defined::{'&undef'}),   'is &undef externally NOT accessible?';

my $a = 42;
my $b = 666;
ok defined($a), 'is $a defined';
ok defined($b), 'is $b defined';
given $a {
    ok defined(), 'is $_ defined';
}

is undef(), Nil, 'does undef() return Nil';
$a = undef();
nok defined($a), 'is $a no longer defined';
is undef($b), Nil, 'does undef(scalar) return Nil';
nok defined($b), 'is $b no longer defined';

my @a = 1,2,3;
my %h = a => 42, b => 666;

is undef(@a), Nil, 'does undef(array) return Nil';
is undef(%h), Nil, 'does undef(%h) return Nil';

is @a.elems, 0, 'was array emptied';
is %h.elems, 0, 'was hash emptied';

# vim: ft=perl6 expandtab sw=4
