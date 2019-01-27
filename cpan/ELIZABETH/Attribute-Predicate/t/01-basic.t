use v6.c;
use Test;

use Attribute::Predicate;

plan 4;

class A {
    has $.a is predicate;
    has $.b is predicate<bazzy>;
}

my $a = A.new(a => 42);
ok $a.has-a,  'is a set';
nok $a.bazzy, 'is b NOT set';

$a = A.new(b => 666);
nok $a.has-a, 'is a NOT set';
ok $a.bazzy,  'is b set';

# vim: ft=perl6 expandtab sw=4
