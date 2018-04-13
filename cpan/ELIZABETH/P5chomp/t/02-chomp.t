use v6.c;
use Test;
use P5chomp;

plan 20;

my $a = "a\n";
is chomp($a), 1, 'did we chomp one';
is $a, "a",      'did we actually chomp';
is chomp($a), 0, 'did we chomp nothing';
is $a, "a",      'did we actually leave it';

$_ = "b\n";
is chomp(), 1, 'did we chomp one';
is $_, "b",    'did we actually chomp';
is chomp(), 0, 'did we chomp nothing';
is $_, "b",    'did we actually leave it';

my @a = "a\n","b\n";
is chomp(@a), 2, 'did we chomp all elements';
is @a[0], "a",   'did we actually chomp 0';
is @a[1], "b",   'did we actually chomp 1';
is chomp(@a), 0, 'did we chomp no elements';
is @a[0], "a",   'did we actually leave 0';
is @a[1], "b",   'did we actually leave 1';

my %h = a => "a\n", b => "b\n";
is chomp(%h), 2, 'did we chomp all values';
is %h<a>, "a",   'did we actually chomp a';
is %h<b>, "b",   'did we actually chomp b';
is chomp(%h), 0, 'did we chomp no values';
is %h<a>, "a",   'did we actually leave a';
is %h<b>, "b",   'did we actually leave b';

# vim: ft=perl6 expandtab sw=4
