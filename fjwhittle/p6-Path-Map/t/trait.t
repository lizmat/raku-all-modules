use v6;

use Test;

use Path::Map :traits;

plan 3;

sub (:$foo!) is Path::Map(:test<foo/:foo>) { "received $foo" };
sub (Int :$bar! where * > 43) is Path::Map(:test<bar/:bar>) { "Really $bar? Wow" };
sub (Int :$bar!) is Path::Map(:test<bar/:bar>) { "$bar bottles of beer" };

my $match = Path::Map<test>.lookup('foo/bar');

ok $match.handler.(|$match.variables) ~~ 'received bar', 'Unconstrained binding';

$match = Path::Map<test>.lookup('bar/42');

ok $match.handler.(|$match.variables) ~~ '42 bottles of beer', 'Binding with type constraints';

ok Path::Map<test>('bar/99')() ~~ 'Really 99? Wow', 'Binding with where';
