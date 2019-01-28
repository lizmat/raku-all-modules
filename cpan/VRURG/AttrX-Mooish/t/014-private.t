use Test;
use AttrX::Mooish;

plan 11;
my $inst;

my class Foo1 {
    has $!bar is mooish(:lazy, :clearer, :predicate);

    method !build-bar {
        "private val";
    }

    method !priv-builder {
        note "Yes, it's me";
    }

    method run-test {
        is $!bar, "private val", "initialized with private builder";
        is self!has-bar, True, "private predicate";
        self!clear-bar;
        is self!has-bar, False, "private clearer works";
    }
}

$inst = Foo1.new;
$inst.run-test;

my class Foo2 {
    has $!bar is mooish(:lazy, :clearer<reset-bar>, :predicate<is-bar-set>);

    method !build-bar { "private value" }
    method run-test {
        nok self!is-bar-set, "private predicate reports attribute not set";
        is $!bar, "private value", "private builder ok";
        ok self!is-bar-set, "private predicate reports attribute is set";
        self!reset-bar;
        nok self!is-bar-set, "private predicate indicate attribute was reset";
    }
}

$inst = Foo2.new;
$inst.run-test;

my class Foo3 {
    has $.bar is mooish( :lazy("pub-build") );
    has $!baz is mooish( :lazy("pub-build") );

    method pub-build {
        "default public"
    }

    method pvt-baz { $!baz }
}

$inst = Foo3.new;
is $inst.bar, "default public", "public attr with public builder";
is $inst.pvt-baz, "default public", "private attr with public builder";

my class Foo4 {
    has $.bar is mooish( lazy=>"pvt-build" );
    has $!baz is mooish( lazy=>"pvt-build" );

    method !pvt-build {
        "default private"
    }

    method pvt-baz { $!baz }
}

$inst = Foo4.new;
is $inst.bar, "default private", "public attr with private builder";
is $inst.pvt-baz, "default private", "private attr with private builder";

done-testing;
# vim: ft=perl6
