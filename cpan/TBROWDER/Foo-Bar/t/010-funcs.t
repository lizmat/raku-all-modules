use v6;
use Test;

use Foo::Bar :ALL;

plan 2;

is foo, 'bar';
is foo('foo'), 'foo';
