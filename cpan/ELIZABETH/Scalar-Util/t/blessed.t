use v6.c;

use Scalar::Util <blessed>;
use Test;

plan 7;

ok defined(&blessed), 'blessed defined';

my $a = 42;

is blessed($a), 'Int', 'is $a an Int';
is blessed(42), 'Int', 'is 42 an Int';

class Foo { class Bar { } }

my $b = Foo.new;
is blessed($b),  'Foo', 'is $b a Foo';
is blessed(Foo),  Nil,  'is Foo a Nil';

my $c = Foo;
is blessed($c),       Nil, 'is $c a Nil';
is blessed(Foo::Bar), Nil, 'is Foo::Bar a Nil';

# vim: ft=perl6 expandtab sw=4
