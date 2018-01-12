use v6.c;

use Scalar::Util <reftype>;
use Test;

plan 4;

ok defined(&reftype), 'reftype defined';

my @a;
my %h;

is reftype(@a), 'ARRAY', 'is reftype of @a an ARRAY';
is reftype(%h), 'HASH',  'is reftype of %h a HASH';
is reftype(42), Nil,     'is reftype of 42 Nil';

# vim: ft=perl6 expandtab sw=4
