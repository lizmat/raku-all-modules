use v6.c;
use Test;
use P5each;

plan 10;

ok defined(::('&each')),        'is &each imported?';
ok !defined(P5each::{'&each'}), 'is &each externally NOT accessible?';

my @a = <a b c d e>;
my @keys;
my @values;

while each(@a) -> ($key,$value) {
    @keys.push($key);
    @values.push($value);
}

is +@a, +@keys,   'did we get the same number of keys for array';
is +@a, +@values, 'did we get the same number of values for array';
is @keys.sort,   "0 1 2 3 4", 'did we get the right keys for array';
is @values.sort, "a b c d e", 'did we get the right values for array';

my %h = a => 1, b => 2, c => 3, d => 4, e => 5;
@keys = ();
@values = ();

while each(%h) -> ($key,$value) {
    @keys.push($key);
    @values.push($value);
}

is +%h, +@keys,   'did we get the same number of keys for hash';
is +%h, +@values, 'did we get the same number of values for hash';
is @keys.sort,   "a b c d e", 'did we get the right keys for hash';
is @values.sort, "1 2 3 4 5", 'did we get the right values for hash';

# vim: ft=perl6 expandtab sw=4
