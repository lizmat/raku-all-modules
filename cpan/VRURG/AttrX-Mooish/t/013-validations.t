use Test;
use AttrX::Mooish;

plan 9;
my $inst;

my class Foo1 {
    has $.bar is rw is mooish(:lazy);
    has $.baz is mooish(:lazy);

    method build-bar { "is bar" }
    method build-baz { "is baz" }
}

$inst = Foo1.new;
lives-ok { $inst.bar = "Fine" }, "assignment to RW attribute";
throws-like { $inst.baz = "Bad"; },
X::Assignment::RO,
message => 'Cannot modify an immutable Str (is baz)',
"assignment to RO attribute failes";

my class Foo2 {
    has Int $.bar is rw is mooish(:lazy);
    has $.baz is mooish(:lazy);

    method build-bar { 1234 }
    method build-baz { "is baz" }
}
$inst = Foo2.new;
lives-ok { $inst.bar = 31415926 }, "assignment of same types";
lives-ok { $inst.bar = Nil }, "assignment of Nil";
throws-like { $inst.bar = "abc" },
            X::TypeCheck::Assignment,
            "assignment to a different attribute type";

my class Foo3 {
    has Str:D $.bar is rw is mooish(:lazy) = "";

    method build-bar { "is bar" }
}

$inst = Foo3.new;
lives-ok { $inst.bar = "a string" }, "assignment of defined value";
throws-like { $inst.bar = Nil },
X::TypeCheck,
"assignment of Nil to a definite type attribute";

my class Foo4 {
    has Str $.bar is rw is mooish(:lazy) where * ~~ /:i ^ a/;

    method build-bar { "a default value" }
}

$inst = Foo4.new;
lives-ok { $inst.bar = "another value" }, "value assigned matches 'where' constraint";
throws-like { $inst.bar = "not allowed" },
X::TypeCheck,
message => q{Type check failed in assignment to $!bar; expected <anon> but got Str ("not allowed")},
"assignment of non-compliant value";

#CATCH { note "Got exception ", $_.WHO; $_.throw}

done-testing;
# vim: ft=perl6
