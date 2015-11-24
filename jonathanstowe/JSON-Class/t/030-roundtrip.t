#!perl6

use v6;
use lib 'lib';
use Test;

use JSON::Class;

class Inner {
    has %.hash;
    has Rat $.rat;
}
class Outer does JSON::Class {
    has Bool $.bool-attr;
    has Str  $.string;
    has Str  @.str-array;
    has Int  $.int;
    has Inner $.inner;
    has $!private = 'private';
}

my $outer = Outer.new(bool-attr => True, string => "string", str-array => <one two three>, int => 42, inner => Inner.new(rat => 4.2, hash => { A => 1, B => 2 }));

my $ret;

lives-ok { $ret = $outer.to-json }, "marshal object with to-json";

my Outer $new;

lives-ok { $new = Outer.from-json($ret) }, "unmarshall to object with from-json";

ok $new.defined, "it's defined";

isa-ok $new, Outer, "its the right kind of object";

is $new.bool-attr, $outer.bool-attr, "bool right";
is $new.string, $outer.string, "string right";
is $new.int, $outer.int, "int right";
is $new.str-array, $outer.str-array, "arrays are the same";
is $new.inner.rat, $outer.inner.rat, "inner class rat the same";
is $new.inner.hash<A>, $outer.inner.hash<A>, "inner hash 1";
is $new.inner.hash<B>, $outer.inner.hash<B>, "inner hash 2";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
