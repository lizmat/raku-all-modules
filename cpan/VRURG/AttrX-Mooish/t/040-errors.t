use Test;
use AttrX::Mooish;

plan 4;
throws-like 
    q<my class Foo1 { has $.bar is rw is mooish(:filter); }; Foo1.new.bar = 123; >,
    X::Method::NotFound,
    message => "No such method 'filter-bar' for invocant of type 'Foo1'",
    "missing filter method"
    ;

throws-like 
    q<my class Foo1 { has $.bar is rw is mooish(:trigger); }; Foo1.new.bar = 123; >,
    X::Method::NotFound,
    message => "No such method 'trigger-bar' for invocant of type 'Foo1'",
    "missing trigger method"
    ;

subtest "Base Errors" => {
    plan 3;
    my $inst;

    throws-like q{my class Foo1 { has $.bar is mooish(:lazy(pi)); }}, 
            X::TypeCheck::MooishOption, "bad option value";

    my class Foo2 {
        has $.bar is mooish(:lazy);
    }

    throws-like { $inst = Foo2.new; $inst.bar; },
        X::Method::NotFound,
        message => q<No such method 'build-bar' for invocant of type 'Foo2'>,
        "missing builder";

    my class Foo4 {
        has Str $.bar is rw is mooish(:lazy) where * ~~ /:i ^ a/;

        method build-bar { "default value" }
    }

    throws-like { $inst = Foo4.new; $inst.bar },
        X::TypeCheck,
        message => q<Type check failed in assignment to $!bar; expected <anon> but got Str ("default value")>,
        "value from builder don't conform 'where' constraint";

        #CATCH { note "Got exception ", $_.WHO; $_.throw}
}

subtest "Nils", {
    plan 1;

    my $inst;

    my class Foo {
        has %.foo is mooish(:lazy);

        method build-foo { }
    }

    $inst = Foo.new;

    throws-like { $inst.foo },
                X::Hash::Store::OddNumber,
                :message(rx:s/^Odd number of elements found where hash initializer expected\:/),
                "hash build returns Nil";
}

done-testing;
# vim: ft=perl6
