#!perl6

use v6;
use Test;

use JSON::Marshal;

class Inner {
    has %.hash = A => 1, B => 2;
    has Rat $.rat = 4.2;
}
class Outer {
    has Bool $.bool = True;
    has Str  $.string = "string";
    has Str  @.str-array = <one two three>;
    has Int  $.int = 42;
    has Inner $.inner = Inner.new;
    has $!private = 'private';
}

my $outer = Outer.new;

my $ret;

lives-ok { $ret = marshal($outer) }, "marshal object";

my %json = from-json($ret);

ok not %json<private>:exists, "didn't get the private attribute";
is %json<bool>, $outer.bool, "bool right";
is %json<string>, $outer.string, "string right";
is %json<int>, $outer.int, "int right";
is %json<str-array>, $outer.str-array, "arrays are the same";
is %json<inner><rat>, $outer.inner.rat, "inner class rat the same";
is %json<inner><hash><A>, $outer.inner.hash<A>, "inner hash 1";
is %json<inner><hash><B>, $outer.inner.hash<B>, "inner hash 2";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
