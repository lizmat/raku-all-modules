use v6;
use Test::When <release>;
BEGIN {
    use Test;
    my $proc = run "./build-tools/pre-install-mod.p6", "./t/p6-Foo-Plugin-Test";
    unless $proc.exitcode == 0 {
        bail-out "Can't install package Foo::Plugin::Test";
    }
}
use lib <t/lib build-tools/lib inst#.test-repo>;
use Test;
use OOPTest;
use OO::Plugin::Manager;
use OO::Plugin;

plan 1;

my $mgr = OO::Plugin::Manager.new( base => 'Foo', :!debug );
$mgr.load-plugins;
$mgr.initialize;

my $registry = Plugin::Registry.instance;

# diag $registry.plugin-types.map( { $mgr.short-name( $_.^name ) } ).Set;
is-deeply $registry.plugin-types.map( { $mgr.short-name( $_.^name ) } ).Set, <Sample TestPlug1 TestPlugin Plug2>.Set, "plugin modules are loaded";

done-testing;

# vim: ft=perl6
