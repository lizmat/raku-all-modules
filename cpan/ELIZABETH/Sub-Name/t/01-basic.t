use v6.c;
use Test;
use Sub::Name;

plan 8;

my $a := subname "foo", { ... };
ok $a ~~ Callable, 'did we get a Callable back?';
is $a.name, "GLOBAL::foo", 'did we get the right name?';

my $b := subname "bar" => { ... };
ok $b ~~ Callable, 'did we get a Callable back?';
is $b.name, "GLOBAL::bar", 'did we get the right name?';

my $c := subname "Zip::foo", { ... };
ok $c ~~ Callable, 'did we get a Callable back?';
is $c.name, "Zip::foo", 'did we get the right name?';

my $d := subname "Zip::bar" => { ... };
ok $d ~~ Callable, 'did we get a Callable back?';
is $d.name, "Zip::bar", 'did we get the right name?';
