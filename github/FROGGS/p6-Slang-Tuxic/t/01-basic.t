use v6;
use lib 'lib';
use Test;
use Slang::Tuxic;

plan 8;

sub foo($a, $b) { $a * $b };

is( (foo 3, 5), 15, 'foo 3, 5'); # <-- yes, that is supposed to look ugly
is foo (3, 5), 15, 'foo (3, 5)';
is foo(3, 5),  15, 'foo(3, 5)';

is 42.fmt('-%d-'), '-42-', 'foo.bar(baz)';
is 42.fmt ('-%d-'), '-42-', 'foo.bar (baz)';
is( (42.fmt: '-%d-'), '-42-', 'foo.bar: baz');

my &bar = sub () { 42 };
is bar(), 42, 'can declare anonymous sub';

my &baz = sub(){21};
is baz(), 21, 'can declare anonymous sub';
