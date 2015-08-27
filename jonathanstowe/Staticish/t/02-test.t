#!perl6

use v6;

use Test;

use lib 'lib';

use Staticish;

class Foo is Static {
    has $.foo is rw;
    method say-foo(Str $say = "say") {
        $say ~ " " ~ $!foo;
    }
}

class Bar is Static {
    has $.foo is rw;
}

class Multi is Static {

    proto multi-foo(|) { * }
    multi method multi-foo(Int $a) {
        "Int $a";
    }
    multi method multi-foo(Str $a) {
        "Str $a";
    }
}

my $a;

lives-ok { $a = Foo.new(foo => "this one") }, "create an object with the trait";
isa-ok($a, Foo, "just check it's the right sort of thing");
ok($a === Foo.new, "and it is the same object when new called again");
is($a.say-foo, "say this one", "object got the correct value (check wrapper)");
is(Foo.say-foo, "say this one", "called as a class method got the attribute");
is(Foo.say-foo("blub"), "blub this one", "check that with an argument");
isa-ok(Bar.new, Bar, "another class doesn't wind up the wrong class");
ok(!Bar.foo.defined, "and the similarly named attribute isn't the same");
lives-ok { Bar.foo = "test test" }, "set attribute with public accessor";
is(Bar.foo, "test test", "and it got set correctly");
is(Foo.foo, "this one", "and just last check on class");
lives-ok { $a = Multi.multi-foo(1) }, "multi";
is($a, "Int 1", "multi works (Int)");
lives-ok { $a = Multi.multi-foo("foo") }, "multi";
is($a, "Str foo", "multi works (Str)");

done;
# vim: expandtab shiftwidth=4 ft=perl6
