use Test;
use AttrX::InitArg;

plan 1;

class Foo {
    has $.attr is init-arg(False) = "foo";
}

is Foo.new(attr => "bar").attr, 'foo';
