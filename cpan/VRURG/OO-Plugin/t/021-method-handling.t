use v6.d;
use lib './t';
use Test;
use OO::Plugin;
use OO::Plugin::Manager;

plan 6;

my $cover-all-count = 0;

class Foo is pluggable {
    method foo is pluggable {
        return pi;
    }

    proto method bar (|) is pluggable {*}
    multi method bar ( Str:D $s ) { "++" ~ $s }
    multi method bar ( Int:D $i ) { -$i }

    method baz ( $arg ) {
        return '{' ~ $arg.WHO ~ '}';
    }
}

plugin Bar {
    method cover-all ( $msg ) is plug-before(<Foo>) {
        $cover-all-count++;
        # note "^^^ Bar::cover-all: handling method ", $msg.method, ", stage ", $msg.stage, " of Foo";
    }

    # method cover-foo ( $msg ) is plug-after(:Foo<foo>) {
    #     note "^^^ Bar::cover-foo: handling after Foo::foo"
    # }
}

plugin Baz after Bar {
    # method cover-foo ( $msg ) is plug-after(:Foo<foo>) {
    #     note "^^^ Baz::cover-foo: handling after Foo::foo";
    # }

    method cover-baz ( $msg, $arg ) is plug-before(:Foo<baz>) {
        isa-ok $arg, OO::Plugin::Manager, "before-handler of baz: argument value";
    }

    proto method cover-bar ($, |) is plug-around(:Foo<bar>) {*}
    multi method cover-bar( $msg, Int:D $i ) {
        is $i, 42, "around handler of bar: argument value";
    }
}

my $mgr = OO::Plugin::Manager.new: :!debug;
$mgr.initialize;

my \c = $mgr.class(Foo);

my $inst = c.new;
is $inst.foo, pi, "return from foo";
is $inst.bar(42), -42, "return from bar";
is $inst.baz($mgr), '{OO::Plugin::Manager}', "return from baz";
is $cover-all-count, 3, "cover-all called for each method";

done-testing;

# vim: ft=perl6
