use v6.d;
use Test;
use OO::Plugin;
use OO::Plugin::Manager;

plan 6;

module Tester {
    class Bar is pluggable {
        method foo {
            return pi;
        }

        proto method bar (|) is pluggable {*}
        multi method bar ( Str:D $s ) { "++" ~ $s }
        multi method bar ( Int:D $i ) { -$i }
    }
}

package Foo::Plugins {

    plugin Fubar demand PluginA, PluginB {
        plugin-meta name => 'Fubarus';

        # Specifying non-existing classes must not fail because they might be loaded/defiend any time later.
        plug-class MyBar for Tester::Bar, A1, A2 is for( <Bar Another>, Tester::Bar ) {
            method bar (|) {
                flunk "this plugin is disabled, this method must never be called";
            }
        }

    }

    plugin P1 after P2 {
        plug-class C1 for Bar, A1 {
            has $.c1-attr is rw;
            method foo {
                "P1::C1+" ~ callsame
            }
        }
    }

    plugin P2 {
        # Despite different naming, C1 from P1 declares same Tester::Bar
        plug-class C1 for Tester::Bar {
            method foo (|) {
                "P2::C1+" ~ callsame
            }
        }
    }
}

my $mgr = OO::Plugin::Manager.new( base => 'Foo', :!debug )
            .load-plugins
            .initialize;

like $mgr.disabled('Fubar'), rx:s/^Demands missing \'Plugin.\' plugin/, "plugin Fubar is disabled";

my \c := $mgr.class(Tester::Bar);

like c.^name, /^Tester '::' Bar_ <[a..zA..Z0..9]> ** 6 $/, "generated new class";
my @roles = Foo::Plugins::P2::C1, Foo::Plugins::P1::C1;
for c.^mro[1..2] -> \parent {
    my \prole = @roles.shift;
    does-ok parent, prole, "does " ~ prole.^name;
}

my $inst = c.new;
is $inst.foo, "P2::C1+P1::C1+" ~ pi, "the inheritance chain was correct";
can-ok $inst, "c1-attr", "rw attribute from a plugin";

done-testing;

# vim: ft=perl6
