use v6.c;
use Test;
use Sub::Util <set_subname>;

plan 22;

my $a := set_subname "foo", { ... }; # 2 positional case
ok $a ~~ Callable, 'did we get a Callable back?';
is $a.name, "GLOBAL::foo", 'did we get the right name?';

my $b := set_subname bar => { ... };  # %_ case
ok $b ~~ Callable, 'did we get a Callable back?';
is $b.name, "GLOBAL::bar", 'did we get the right name?';

my $c := set_subname "baz" => { ... }; # Pair case
ok $c ~~ Callable, 'did we get a Callable back?';
is $c.name, "GLOBAL::baz", 'did we get the right name?';

package Foo {  # check specific package name
    my $a := set_subname "foo", { ... }; # 2 positional case
    ok $a ~~ Callable, 'did we get a Callable back?';
    is $a.name, "Foo::foo", 'did we get the right name?';

    my $b := set_subname bar => { ... };  # %_ case
    ok $b ~~ Callable, 'did we get a Callable back?';
    is $b.name, "Foo::bar", 'did we get the right name?';

    my $c := set_subname "baz" => { ... }; # Pair case
    ok $c ~~ Callable, 'did we get a Callable back?';
    is $c.name, "Foo::baz", 'did we get the right name?';
}

package Foo {
    package Bar {  # check nested package name
        my $a := set_subname "foo", { ... }; # 2 positional case
        ok $a ~~ Callable, 'did we get a Callable back?';
        is $a.name, "Foo::Bar::foo", 'did we get the right name?';

        my $b := set_subname bar => { ... };  # %_ case
        ok $b ~~ Callable, 'did we get a Callable back?';
        is $b.name, "Foo::Bar::bar", 'did we get the right name?';

        my $c := set_subname "baz" => { ... }; # Pair case
        ok $c ~~ Callable, 'did we get a Callable back?';
        is $c.name, "Foo::Bar::baz", 'did we get the right name?';
    }
}


my $d := set_subname "Zip::foo", { ... }; # 2 positional case
ok $d ~~ Callable, 'did we get a Callable back?';
is $d.name, "Zip::foo", 'did we get the right name?';

my $e := set_subname "Zip::baz" => { ... }; # Pair case
ok $e ~~ Callable, 'did we get a Callable back?';
is $e.name, "Zip::baz", 'did we get the right name?';

# vim: ft=perl6 expandtab sw=4
