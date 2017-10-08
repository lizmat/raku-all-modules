use v6;

use Test;

use Path::Map :traits;

plan 4;

sub (:$foo!) is Path::Map(:test<foo/:foo>) { "received $foo" };
sub (Int :$bar! where * > 43) is Path::Map(:test<bar/:bar>) { "Really $bar? Wow" };
sub (Int :$bar!) is Path::Map(:test<bar/:bar>) { "$bar bottles of beer" };
sub ($foo, $bar, Int :$baz!, :$qux) is Path::Map(:test<baz/:baz/*>) { @( $foo, $bar, $baz, $qux ) };

my $match = Path::Map<test>.lookup('foo/bar');

ok $match.handler.(|$match.variables) ~~ 'received bar', 'Unconstrained binding';

$match = Path::Map<test>.lookup('bar/42');

ok $match.handler.(|$match.variables) ~~ '42 bottles of beer', 'Binding with type constraints';

ok Path::Map<test>('bar/99')() ~~ 'Really 99? Wow', 'Binding with where';

ok Path::Map<test>('baz/3/2')(1, :qux<4>) ~~ @( 1, 2, 3, 4 ), 'Wildcard and unbound parameters';
