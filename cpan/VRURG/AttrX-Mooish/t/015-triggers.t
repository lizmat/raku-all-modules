use Test;
use AttrX::Mooish;

plan 1;

subtest "Triggers", {
    plan 12;
    my $inst;
    my class Foo1 {
        has $.bar is rw is mooish(:trigger);
        has $.baz is rw is mooish(:trigger<on_change>);
        has $.foo is rw is mooish(:trigger(method ($value) {
            pass "in-place trigger";
            is $value, "foo value", "valid value passed to in-place";
        }));
        has $.fubar is rw is mooish(:trigger(-> $,$value,*% {
            pass "pointy-block trigger";
            is $value, "fubar value", "valid value passed to pointy block";
        }));

        method trigger-bar ( $value ) {
            pass "trigger for attribute $!bar";
            is $value, "bar value", "valid value passed to trigger";
        }

        method on_change ( $value, :$attribute ) {
            pass "generic trigger on_chage()";
            is $value, "baz value", "valid value passed to on_change";
            is $attribute, <$!baz>, "received attribute name";
        }
    }

    $inst = Foo1.new;
    $inst.bar = "bar value";
    $inst.baz = "baz value";
    $inst.foo = "foo value";
    $inst.fubar = "fubar value";

    my class Foo2 {
        has $.bar is rw is mooish(:lazy, :trigger);

        method build-bar { "build bar" }
        method trigger-bar ( $value ) { is $value, "build bar", "trigger on lazy build" }
    }

    $inst = Foo2.new;
    $inst.bar;

    my class Foo3 {
        has $.bar is rw is mooish(:lazy, :trigger);

        method build-bar { "from builder" }
        method trigger-bar ( $value, *%opt ) {
            if $value ~~ "from builder" {
                ok %opt<builder>, "builder option is set";
            }
            else {
                nok %opt<builder>:exists, "no builder option";
            }
        }
    }

    $inst = Foo3.new;
    $inst.bar;
    $inst.bar = "not from builder";
}

done-testing;
# vim: ft=perl6
