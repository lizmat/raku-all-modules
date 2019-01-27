use v6.c;
use Test;

use Method::Also;

plan 7;

class A {
    has $.foo;
    method foo() is also<bar bazzy> is rw { $!foo }
}

my $a = A.new(foo => 42);
is $a.foo,   42, 'the original foo';
is $a.bar,   42, 'the first alias bar';
is $a.bazzy, 42, 'the second alias bazzy';

class Bar {
    multi method foo()     is also<bar>   { 42 }
    multi method foo($foo) is also<bazzy> { $foo }
}

is Bar.foo,         42, 'is foo() ok';
is Bar.foo(666),   666, 'is foo(666) ok';
is Bar.bar,         42, 'is bar() ok';
is Bar.bazzy(768), 768, 'is bazzy(768) ok';

# vim: ft=perl6 expandtab sw=4
