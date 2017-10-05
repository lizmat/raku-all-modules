use v6;
use Test;

use Foo::Bar :ALL;

plan 3;

is foo, 'bar';
is foo('foo'), 'foo';

is baz, 'baz';

