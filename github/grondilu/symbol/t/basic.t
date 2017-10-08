use Test;
use Symbol;

my $foo1 = s:foo1;
my $foo2 = s:foo2;

my %hash;
%hash<foo> = "bar";
%hash{$foo1} = "bar!";
%hash{$foo2} = "bar!!";

plan 3;

isnt %hash<foo>, %hash{$foo1};
isnt %hash<foo>, %hash{$foo2};
isnt $foo1, $foo2;



