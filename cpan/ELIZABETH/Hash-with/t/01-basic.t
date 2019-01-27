use v6.c;
use Test;
use Hash-with;

plan 9;

my %h1 does Hash-lc = "A", 42;
is %h1<a>, 42,    'does lower case give right answer';
is %h1<A>, 42,    'does upper case give right answer';
is %h1.keys, "a", 'was a lower case key stored';

my %h2 does Hash-uc = a => 42;             # map all keys to uppercase
is %h2<a>, 42,    'does lower case give right answer';
is %h2<A>, 42,    'does upper case give right answer';
is %h2.keys, "A", 'was a upper case key stored';

sub ordered($a) { $a.comb.sort.join }
my %h3 does Hash-with[&ordered] = oof => 42;  # order all keys
is %h3<foo>, 42,    'does ordered case give right answer';
is %h3<ofo>, 42,    'does mixed case give right answer';
is %h3.keys, "foo", 'was a ordered case key stored';

# vim: ft=perl6 expandtab sw=4
