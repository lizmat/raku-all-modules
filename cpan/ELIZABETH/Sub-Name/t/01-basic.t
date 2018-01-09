use v6.c;
use Test;
use Sub::Name;

plan 10;

my $a := subname "foo", { ... }; # 2 positional case
ok $a ~~ Callable, 'did we get a Callable back?';
is $a.name, "GLOBAL::foo", 'did we get the right name?';

my $b := subname bar => { ... };  # %_ case
ok $b ~~ Callable, 'did we get a Callable back?';
is $b.name, "GLOBAL::bar", 'did we get the right name?';

my $c := subname "baz" => { ... }; # Pair case
ok $c ~~ Callable, 'did we get a Callable back?';
is $c.name, "GLOBAL::baz", 'did we get the right name?';

my $d := subname "Zip::foo", { ... }; # 2 positional case
ok $d ~~ Callable, 'did we get a Callable back?';
is $d.name, "Zip::foo", 'did we get the right name?';

my $e := subname "Zip::baz" => { ... }; # Pair case
ok $e ~~ Callable, 'did we get a Callable back?';
is $e.name, "Zip::baz", 'did we get the right name?';

# vim: ft=perl6 expandtab sw=4
