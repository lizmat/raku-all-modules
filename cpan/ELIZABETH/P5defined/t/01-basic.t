use v6.c;
use Test;
use P5defined;

plan 9;

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

$a = undef();
nok defined($a), 'is $a no longer defined';
undef($b);
nok defined($b), 'is $b no longer defined';

# vim: ft=perl6 expandtab sw=4
