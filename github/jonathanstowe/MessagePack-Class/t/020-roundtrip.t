#!/usr/bin/env perl6

use v6.c;

use Test;

use MessagePack::Class;

class Inner {
    has %.hash;
    has Str $.inner-str;

}
class TestClass does MessagePack::Class {
    has Str     $.string;
    has Bool    $.bool;
    has Int     $.int;
    has Rat     $.num;
    has Inner   $.inner;
}

my $inner = Inner.new(inner-string => "inner value", hash => { A => 4, B => 6 });
my $original = TestClass.new(string => "test value", bool => True, int => 42, num => 2.5, :$inner );

my $pack;

lives-ok { $pack = $original.to-messagepack }, "to messagepack";
ok $pack ~~ Blob, "and we got a Blob back";

my $new;

lives-ok { $new = TestClass.from-messagepack($pack) }, "from messagepack";

is $new.string, $original.string, "got right string value";
is $new.bool, $original.bool, "got right bool value";
is $new.int, $original.int, "got right int value";
is $new.num, $original.num, "got right num value";
isa-ok $new.inner, Inner;
is $new.inner.inner-str, $original.inner.inner-str, "got inner string value";
is $new.inner.hash<A>, $original.inner.hash<A>, "got the inner hash too";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
