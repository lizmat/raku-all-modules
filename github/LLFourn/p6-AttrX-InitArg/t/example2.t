use Test;
use AttrX::InitArg;

plan 2;

class Foo {
    has $.attr is init-arg('other-name');
}

is Foo.new(other-name => "bar").attr,'bar';
ok Foo.new(attr => "bar").attr === Any;
