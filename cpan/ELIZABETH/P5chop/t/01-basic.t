use v6.c;
use Test;
use P5chop;

plan 12;

ok defined(::('&chop')),        'is &chop imported?';
ok !defined(P5chop::{'&chop'}), 'is &chop externally NOT accessible?';

my $a = "ab";
is chop($a), "b", 'did we chop one';
is $a, "a",       'did we actually chop';

$_ = "bc";
is chop(), "c", 'did we chop one';
is $_, "b",     'did we actually chop';

my @a = "ab","bc";
is chop(@a), "c", 'did we chop all elements';
is @a[0], "a",    'did we actually chop 0';
is @a[1], "b",    'did we actually chop 1';

my %h = a => "ab", b => "bc";
ok chop(%h) eq any(<b c>), 'did we chop all values';
is %h<a>, "a",   'did we actually chop a';
is %h<b>, "b",   'did we actually chop b';

# vim: ft=perl6 expandtab sw=4
